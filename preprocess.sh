#!/bin/bash
#SBATCH --job-name=NORDIC-test
#SBATCH --output=logs/%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=0:05:00
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

# getting subject info
mapfile -t subs < $participant_file
sub=${subs[$SLURM_ARRAY_TASK_ID]}
echo "Processing sub $sub"

export SUBBIDS="${BIDSDIR}/sub-${sub}"
export PROCDIR="${DATADIR}/processed/sub-${sub}"
mkdir -p $PROCDIR

# loads required module
module load matlab
module load fsl
module load python
module load dcm2niix
source ${BASEDIR}/dcm2bids_env/bin/activate

# 1) CONVERTING DICOM INTO NIFTI

if [ ! -d ${DICOMDIR}/sub-${sub} ]; then
	echo "Convert dicom to nifti for ${sub}"
	dcm2bids -d "${DICOMDIR}/sub-${sub}" -p ${sub} -c "${BASEDIR}/bids-config.json" -o ${BIDSDIR}
else
	echo "BIDS conversion already completed for ${sub}"
fi

# identifying target scans
cd "${SUBBIDS}/func"
vaso=$(find -name "*vaso.nii" -printf "%P\n")
bold=$(find -name "*bold.nii" -printf "%P\n")
echo "Vaso scans are $vaso"
echo "Bold scans are $bold"

# 2) DEFACING SCANS

anat_tags=("UNIT1" "T1map" "INV1" "INV2")

cd "${SUBBIDS}/anat"

orig=$(find -name "original*.nii" -printf "%P\n")
if [ ${#orig[@]} -gt 0 ]; then

	echo "Defacing already completed for $sub"

else

	for tag in "${anat_tags[@]}"; do
		echo "Defacing $tag scan for $sub"
		scan=$(find -name "*${tag}.nii" -printf "%P\n")
		pydeface $scan

		echo "Renaming defaced scan"
		mv $scan "original-${scan}"
		nodeface=$(find -name "*defaced.nii" -printf "%P\n")
		mv $nodeface $scan
	done
fi

# 3) NORDIC DENOISING

echo "Applying NORDIC denoising to $sub"
matlab -batch "addpath('${CODEDIR}'); [bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); PROC_nordic_denoising('0', bold, vaso, '${SUBBIDS}', '${PROCDIR}', '', 'nord'); exit"

