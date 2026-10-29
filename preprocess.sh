#!/bin/bash
#SBATCH --job-name=PREPROC
#SBATCH --output=logs/%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=5:00:00
#SBATCH --mem-per-cpu=10000

BASEDIR=$(pwd)
NUM_ANAT=4 # number of anatomical scans

# directory list
export DATADIR="${BASEDIR}/data"
export BIDSDIR="${DATADIR}/bids"
export DICOMDIR="${DATADIR}/dicom"
export CODEDIR="${BASEDIR}/code"
export APPDIR="${BASEDIR}/software"
participant_file="${BIDSDIR}/participants.tsv"
config_file="${BASEDIR}/bids-config.json"

# adding software to path
export PATH="${APPDIR}/LayNii:${PATH}"

# getting subject info
mapfile -t subs < $participant_file
sub=${subs[$SLURM_ARRAY_TASK_ID]}
echo -e "Processing sub $sub\n"

export SUBBIDS="${BIDSDIR}/sub-${sub}"
export PROCDIR="${DATADIR}/processed/sub-${sub}"
export ANATDIR="${PROCDIR}/anat"
mkdir -p $PROCDIR $ANATDIR

# loads required modules
module load matlab
module load fsl
module load afni
module load python
module load dcm2niix
source ${BASEDIR}/dcm2bids_env/bin/activate

# 1) CONVERTING DICOM INTO NIFTI

echo "-------------------------------------------"
echo -e "\nApplying bids conversion to $sub\n"
echo "-------------------------------------------"


if [ ! -d ${SUBBIDS} ]; then
	echo -e "Convert dicom to nifti for ${sub}\n"
	dcm2bids -d "${DICOMDIR}/sub-${sub}" -p ${sub} -c "${BASEDIR}/bids-config.json" -o ${BIDSDIR}
else
	echo -e "BIDS conversion already completed for ${sub}\n"
fi

# identifying target scans
cd "${SUBBIDS}/func"
vaso=$(find -maxdepth 1 -name "*vaso.nii" -printf "%P\n")
bold=$(find -maxdepth 1 -name "*bold.nii" -printf "%P\n")
echo -e "Vaso scans are $vaso\n"
echo -e "Bold scans are $bold\n"

# 2) DEFACING SCANS

echo "-------------------------------------------"
echo -e "\nApplying defacing to $sub\n"
echo "-------------------------------------------"

anat_tags=("UNIT1" "T1map" "INV1" "INV2")

cd "${SUBBIDS}/anat"

for tag in "${anat_tags[@]}"; do
	scan="sub-${sub}_acq-mp2rage_${tag}.nii"
	echo -e "Found scan for ${tag} as ${scan}\n"
	if [ -f "${SUBBIDS}/anat/original-${scan}" ]; then
		echo -e "Skipping: File ${scan} already defaced.\n"
	else
		echo -e "Defacing $tag scan for $sub\n"
		pydeface $scan
		echo -e "Renaming defaced scan\n"
		mv -v $scan "original-${scan}"
		defaced="sub-${sub}_acq-mp2rage_${tag}_defaced.nii"
		mv -v $defaced $scan
	fi
done

# 3) NORDIC DENOISING

cd ${PROCDIR}
echo "-------------------------------------------"
echo -e "\nApplying NORDIC denoising to $sub\n"
echo "-------------------------------------------"

PREFIX_NORD="nord-"

for runtype in ${RUNTYPES[@]}; do

	matlab -batch " \
		addpath('${CODEDIR}'); \
		addpath(genpath('${APPDIR}')); \
		[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
		PROC_nordic_denoising('0', ${runtype}, '${runtype}', '${SUBBIDS}/func', '${PROCDIR}', '', '${PREFIX_NORD}'); \
		exit \
	"
done

# Renaming files
rename '.nii.nii' '.nii' *
# might want to delete the .mat files produced

# 4) MOTION CORRECTION

PREFIX_MOCO="moco-"

echo "-------------------------------------------"
echo -e "\nApplying motion correction to $sub\n"
echo "-------------------------------------------"

for runtype in ${RUNTYPES[@]}; do

	matlab -batch " \
		addpath('${CODEDIR}'); \
		addpath(genpath('${APPDIR}')); \
		[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
		PROC_motion_correction(${runtype}, '${runtype}', '${PROCDIR}', '${PROCDIR}', '${PREFIX_NORD}', '${PREFIX_MOCO}'); \
		exit \
	"
done

# Renaming files

rename 'meannord-' 'mean-' *
rename "${PREFIX_MOCO}${PREFIX_NORD}" "${PREFIX_MOCO}" *
rename 'rp_nord-' 'rp_' *

# 5) BOLD CORRECTION

echo "-------------------------------------------"
echo -e "\nApplying BOLD correction to $sub\n"
echo "-------------------------------------------"

for vasorun in $vaso; do

	# checks if step already run
	if [ -f "${PROCDIR}/noboco-${vasorun}" ]; then
		echo -e "Skipping run ${vasorun}\n"
		continue
	fi

	boldrun="${vasorun/vaso/bold}"

	echo "Correcting run $vasorun"
	LN_BOCO -Nulled "${PROCDIR}/${PREFIX_MOCO}${vasorun}" -BOLD "${PROCDIR}/${PREFIX_MOCO}${boldrun}"
	echo "Renaming files..."
	mv -v "${PROCDIR}/${PREFIX_MOCO}${vasorun}" "${PROCDIR}/noboco-${vasorun}"
	mv -v "${PROCDIR}/VASO_LN.nii" "${PROCDIR}/${PREFIX_MOCO}${vasorun}"

done

# 5.5) REGISTRATION PREPERATION

echo "-------------------------------------------"
echo -e "\nChecking motion correction details for $sub\n"
echo "-------------------------------------------"

for runtype in ${RUNTYPES[@]}; do

	matlab -batch " \
		addpath('${CODEDIR}'); \
		[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
		PROC_view_moco(${runtype}, '${runtype}','${PROCDIR}','${PROCDIR}'); \
		exit \
	"
done

echo "************************************"
echo "COMPLETED PREPROCESSING PHASE 1!"
echo "************************************"

# 6) COREGISTRATION (func to anat)

echo "-------------------------------------------"
echo -e "\nApplying anat2func coregistration for $sub\n"
echo "-------------------------------------------"

PREFIX_COREG="creg-"

# creating link to anat file
ln -s "${SUBBIDS}/anat/sub-${sub}_acq-mp2rage_UNIT1.nii" "${ANATDIR}/sub-${sub}_acq-mp2rage_UNIT1.nii"

for runtype in ${RUNTYPES[@]}; do

	matlab -batch " \
		addpath('${CODEDIR}'); \
		addpath(genpath('${APPDIR}')); \
		[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
		PROC_coregistration(${runtype},'${runtype}',anat,'${PROCDIR}','${ANATDIR}','${PREFIX_MOCO}','${PREFIX_COREG}'); \
		exit \
	"
done

rename "${PREFIX_COREG}${PREFIX_MOCO}" "${PREFIX_COREG}" *

# 7) SEGMENTATION

echo "-------------------------------------------"
echo -e "\nApplying segmentation for $sub\n"
echo "-------------------------------------------"

for runtype in ${RUNTYPES[@]}; do

	matlab -batch " \
		addpath('${CODEDIR}'); \
		addpath(genpath('${APPDIR}')); \
		[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
		PROC_segmentation(${runtype},'${runtype}','${ANATDIR}','${APPDIR}/spm'); \
		exit \
	"
done

# moving outputs to processing folder
mv -v ${PROCDIR}/c?anat*nii "${ANATDIR}"
mv -v ${PROCDIR}/y_*nii "${ANATDIR}"
mv -v ${PROCDIR}/manat*nii "${ANATDIR}"

# 8) NORMALIZATION

echo "-------------------------------------------"
echo -e "\nApplying normalization for $sub\n"
echo "-------------------------------------------"

PREFIX_NORM="normal-"

for runtype in ${RUNTYPES[@]}; do

	matlab -batch " \
		addpath('${CODEDIR}'); \
		addpath(genpath('${APPDIR}')); \
		[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
		PROC_normalization(${runtype},'${runtype}','${ANATDIR}','${PROCDIR}','${PREFIX_COREG}','${PREFIX_NORM}'); \
		exit \
	"
done

rename "${PREFIX_NORM}${PREFIX_COREG}" "${PREFIX_NORM}" *

# 9) SMOOTHING

echo "-------------------------------------------"
echo -e "\nApplying smoothing for $sub\n"
echo "-------------------------------------------"

PREFIX_SMOOTH="PROC-"

for runtype in ${RUNTYPES[@]}; do

	matlab -batch " \
		addpath('${CODEDIR}'); \
		addpath(genpath('${APPDIR}')); \
		[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
		PROC_smoothing(${runtype},'${runtype}','${PROCDIR}','${PREFIX_NORM}','${PREFIX_SMOOTH}'); \
		exit \
	"
done

rename "${PREFIX_SMOOTH}${PREFIX_NORM}" "${PREFIX_SMOOTH}" *

echo "************************************"
echo "COMPLETED PREPROCESSING PHASE 2!"
echo "************************************"
