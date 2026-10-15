#!/bin/bash
#SBATCH --job-name=PREPROC
#SBATCH --output=logs/%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=10000

ANALYSIS_TYPE="functional"
PREFIX="REG-"
RUNTYPES=("bold" "vaso")
dx=4
dy=1
dz=4

# directory list
BASEDIR=$(pwd)
export DATADIR="${BASEDIR}/data"
export BIDSDIR="${DATADIR}/bids"
export BADEDIR="${DATADIR}/bade_fmri_task"
export CODEDIR="${BASEDIR}/code"
export APPDIR="${BASEDIR}/software"

participant_file="${BIDSDIR}/participants.tsv"
scan_file="${BIDSDIR}/scaninfo-file.tsv"
condition_file="${BADEDIR}/condition-info.csv"
contrast_file="${BADEDIR}/contrast-info.csv"

# getting subject info
mapfile -t subs < $participant_file
sub=${subs[$SLURM_ARRAY_TASK_ID]}
echo -e "Processing sub $sub\n"

timing_file="${BADEDIR}/sub-${sub}_bade-fmri_timing-vectors.mat"

# getting scan info
TR=$(grep "${sub}" "${scan_file}" | cut -f2)
N_CONTRASTS=$(cat "${contrast_file}" | wc -l)

export SUBBIDS="${BIDSDIR}/sub-${sub}"
export PROCDIR="${DATADIR}/processed/sub-${sub}"
export OUTDIR="${BASEDIR}/output/${ANALYSIS_TYPE}/sub-${sub}"
mkdir -p "${OUTDIR}" "${OUTDIR}/fla-bold" "${OUTDIR}/fla-vaso"

# loads required modules
module load matlab
module load afni
module load python

# 0) GENERATING TIMING VECTORS

if [ -f "${timing_file}" ]; then
	echo -e "Timing vectors already generated for ${sub}\n"
else
	echo -e "Generating timing vectors for ${sub}\n"
	python "${CODEDIR}/generate-timing-vectors.py" "${sub}"
fi

# 1) FIRST-LEVEL ANALYSIS

echo "-------------------------------------------"
echo -e "\nProcessing first level analysis on $sub\n"
echo "-------------------------------------------"

cd "${OUTDIR}"
vaso=$(find -maxdepth 1 -name "*vaso.nii" -printf "%P\n")
bold=$(find -maxdepth 1 -name "*bold.nii" -printf "%P\n")
echo -e "Vaso scans are $vaso\n"
echo -e "Bold scans are $bold\n"

matlab -batch "
	addpath('${CODEDIR}');
	addpath(genpath('${APPDIR}'));
	[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}');
	ANALYSIS_first_level('${sub}',bold,'bold','${TR}','${condition_file}','${PROCDIR}','${PREFIX}', '${timing_file}','${OUTDIR}/fla-bold');
	ANALYSIS_first_level('${sub}',vaso,'vaso','${TR}','${condition_file}','${PROCDIR}','${PREFIX}', '${timing_file}','${OUTDIR}/fla-vaso');
	exit
"

# 2) CONTRAST ANALYSIS

echo "-------------------------------------------"
echo -e "\nExtracting contrasts for $sub\n"
echo "-------------------------------------------"

matlab -batch "
	addpath('${CODEDIR}');
	addpath(genpath('${APPDIR}'));
	[bold, vaso, anat] = get_images('${sub}', '${SUBBIDS}');
	ANALYSIS_contrast('bold','${contrast_file}','${OUTDIR}/fla-bold');
	ANALYSIS_contrast('vaso','${contrast_file}','${OUTDIR}/fla-vaso');
	exit
"

# 3) UPSAMPLING IMAGES

for runtype in ${RUNTYPES[@]}; do

	updir="${OUTDIR}/fla-${runtype}"
	cd "${updir}"
	for (( i=1; i<=${N_CONTRASTS}; i++ )); do
		img="spmT_000${i}.nii"
		echo -e "Upsampling contrast image ${img}\n"
		3dresample -input "${updir}/${img}" -prefix "${updir}/Up_${img}" -dxyz $dx $dy $dz -overwrite
	done

	t1like="sub-${sub}_t1-like_${runtype}.nii"
	echo -e "Upsampling t1-like image\n"
	3dresample -input "${PROCDIR}/${t1like}" -prefix "${updir}/Up_${t1like}" -dxyz $dx $dy $dz -overwrite

done

echo "*************************************"
echo "   COMPLETED FIRST LEVEL ANALYSIS!"
echo "*************************************"

