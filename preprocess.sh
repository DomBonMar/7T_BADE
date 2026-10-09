#!/bin/bash
#SBATCH --job-name=PREPROC
#SBATCH --output=logs/%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=2:30:00
#SBATCH --mem-per-cpu=10000

BASEDIR=$(pwd)

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
mkdir -p $PROCDIR

# loads required modules
module load matlab
module load fsl
module load afni
module load python
module load dcm2niix
source ${BASEDIR}/dcm2bids_env/bin/activate

# 1) CONVERTING DICOM INTO NIFTI

if [ ! -d ${SUBBIDS} ]; then
	echo -e "Convert dicom to nifti for ${sub}\n"
	dcm2bids -d "${DICOMDIR}/sub-${sub}" -p ${sub} -c "${BASEDIR}/bids-config.json" -o ${BIDSDIR}
else
	echo -e "BIDS conversion already completed for ${sub}\n"
fi

# identifying target scans
cd "${SUBBIDS}/func"
vaso=$(find -name "*vaso.nii" -printf "%P\n")
bold=$(find -name "*bold.nii" -printf "%P\n")
echo -e "Vaso scans are $vaso\n"
echo -e "Bold scans are $bold\n"

# 2) DEFACING SCANS

anat_tags=("UNIT1" "T1map" "INV1" "INV2")

cd "${SUBBIDS}/anat"

orig=$(find -name "original*.nii" -printf "%P\n")
if [ ${#orig[@]} -gt 0 ]; then

	echo -e "Defacing already completed for $sub\n"

else

	for tag in "${anat_tags[@]}"; do
		echo -e "Defacing $tag scan for $sub\n"
		scan=$(find -name "*${tag}.nii" -printf "%P\n")
		pydeface $scan

		echo -e "Renaming defaced scan\n"
		mv $scan "original-${scan}"
		nodeface=$(find -name "*defaced.nii" -printf "%P\n")
		mv $nodeface $scan
	done
fi

# 3) NORDIC DENOISING

cd ${PROCDIR}
echo "-------------------------------------------"
echo -e "Applying NORDIC denoising to $sub\n"
echo "-------------------------------------------"
matlab -batch "addpath('${CODEDIR}'); addpath(genpath('${APPDIR}')); [bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); PROC_nordic_denoising('0', bold, 'bold', '${SUBBIDS}/func', '${PROCDIR}', '', 'nord-'); PROC_nordic_denoising('0', vaso, 'vaso', '${SUBBIDS}/func', '${PROCDIR}', '', 'nord-'); exit"

# Renaming files
rename '.nii.nii' '.nii' *
# might want to delete the .mat files produced

# 4) MOTION CORRECTION

echo "-------------------------------------------"
echo -e "\nApplying motion correction to $sub\n"
echo "-------------------------------------------"

echo -e "\nApplying motion correction to $sub\n"
matlab -batch "addpath('${CODEDIR}'); addpath(genpath('${APPDIR}')); [bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); PROC_motion_correction(bold, 'bold', '${PROCDIR}', '${PROCDIR}', 'nord-', 'moco-'); PROC_motion_correction(vaso, 'vaso', '${PROCDIR}', '${PROCDIR}', 'nord-', 'moco-'); exit"

# Renaming files

rename 'meannord-' 'mean-' *
rename 'moco-nord-' 'moco-' *
rename 'rp_nord-' 'rp_' *

# 5) BOLD CORRECTION

echo "-------------------------------------------"
echo -e "Applying BOLD correction to $sub\n"
echo "-------------------------------------------"

for vasorun in $vaso; do

	# checks if step already run
	if [ -f "${PROCDIR}/noboco-${vasorun}" ]; then
		echo -e "Skipping run ${vasorun}\n"
		continue
	fi

	boldrun="${vasorun/vaso/bold}"

	echo "Correcting run $vasorun"
	LN_BOCO -Nulled "${PROCDIR}/moco-${vasorun}" -BOLD "${PROCDIR}/moco-${boldrun}"
	echo "Renaming files..."
	mv -v "${PROCDIR}/moco-${vasorun}" "${PROCDIR}/noboco-${vasorun}"
	mv -v "${PROCDIR}/VASO_LN.nii" "${PROCDIR}/moco-${vasorun}"

done

# 6) REGISTRATION PREPERATION

echo "Checking motion registration details"
matlab -batch "addpath('${CODEDIR}'); [bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); PROC_view_moco(bold, 'bold','${PROCDIR}','${PROCDIR}'); PROC_view_moco(vaso, 'vaso','${PROCDIR}','${PROCDIR}'); exit"

echo "************************************"
echo "COMPLETED PREPROCESSING PHASE 1!"
echo "************************************"
