#!/bin/bash
#SBATCH --job-name=REGISTER
#SBATCH --output=logs/%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=10000

BASEDIR=$(pwd)

# directory list
export DATADIR="${BASEDIR}/data"
export BIDSDIR="${DATADIR}/bids"
export CODEDIR="${BASEDIR}/code"
export APPDIR="${BASEDIR}/software"

participant_file="${BIDSDIR}/participants.tsv"
motion_file="${BIDSDIR}/motion.tsv"

# getting subject info
mapfile -t subs < $participant_file
sub=${subs[$SLURM_ARRAY_TASK_ID]}
echo -e "Processing sub $sub\n"

# getting target motion file info
target_run=$(grep "${sub}" "${motion_file}" | cut -f2)

export SUBBIDS="${BIDSDIR}/sub-${sub}"
export PROCDIR="${DATADIR}/processed/sub-${sub}"

# loads required modules
module load matlab
module load afni

cd "${SUBBIDS}/func"
vaso=$(find -name "*vaso.nii" -printf "%P\n")
bold=$(find -name "*bold.nii" -printf "%P\n")
echo -e "Vaso scans are $vaso\n"
echo -e "Bold scans are $bold\n"

# 1) GENERATING T1-LIKE IMAGES

echo "-------------------------------------------"
echo -e "\nGenerating t1-like image for $sub\n"
echo "-------------------------------------------"

cd "${PROCDIR}"

mean_bold="${PROCDIR}/mean-sub-${sub}_task-bade_run-0${target_run}_bold.nii"
mean_vaso="${PROCDIR}/mean-sub-${sub}_task-bade_run-0${target_run}_vaso.nii"
t1_like="${PROCDIR}/sub-${sub}_t1-like_run-0${target_run}.nii"
t1_bold="${PROCDIR}/sub-${sub}_t1-like_bold.nii"
t1_vaso="${PROCDIR}/sub-${sub}_t1-like_vaso.nii"

3dcalc -a "${mean_bold}" -b "${mean_vaso}" -expr "(a+b)/(a-b)" -datum float -prefix "${t1_like}" -overwrite

echo "Making copies of t1-like"
cp -v "${t1_like}" "${t1_bold}"
cp -v "${t1_like}" "${t1_vaso}"

# 2) REGISTRATION STEP

echo "-------------------------------------------"
echo -e "\nApplying functional registration for $sub\n"
echo "-------------------------------------------"

matlab -batch " \
	addpath('${CODEDIR}'); \
	addpath(genpath('${APPDIR}')); \
	[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
	REG_coregistration(bold,'bold','${mean_bold}', '${t1_bold}', '${PROCDIR}', 'moco-', 'reg-'); \
	REG_coregistration(vaso,'vaso','${mean_vaso}', '${t1_vaso}', '${PROCDIR}', 'moco-', 'reg-'); \
	exit \
"

echo -e "Renaming registered files\n"
rename "reg-moco-" "reg-" *

# 3) ALIGNMENT STEP

target_bold="${PROCDIR}/reg-sub-${sub}_task-bade_run-0${target_run}_bold.nii"
target_vaso="${PROCDIR}/reg-sub-${sub}_task-bade_run-0${target_run}_vaso.nii"

matlab -batch " \
	addpath('${CODEDIR}'); \
	addpath(genpath('${APPDIR}')); \
	[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}'); \
	REG_alignment(bold,'bold', '${target_bold}', '${t1_bold}', '${PROCDIR}', 'reg-', 'REG-'); \
	REG_alignment(vaso,'vaso', '${target_vaso}', '${t1_vaso}', '${PROCDIR}', 'reg-', 'REG-'); \
	exit \
"

echo "************************************"
echo "COMPLETED REGISTRATION PHASE!"
echo "************************************"

