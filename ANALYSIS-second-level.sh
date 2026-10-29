#!/bin/bash
#SBATCH --job-name=GROUP
#SBATCH --output=logs/%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=0:20:00
#SBATCH --mem-per-cpu=10000

ANALYSIS_TYPE="functional"
RUNTYPES=("bold" "vaso")

# directory list
BASEDIR=$(pwd)
export DATADIR="${BASEDIR}/data"
export BIDSDIR="${DATADIR}/bids"
export BADEDIR="${DATADIR}/bade_fmri_task"
export CODEDIR="${BASEDIR}/code"
export APPDIR="${BASEDIR}/software"

subject_file="${BIDSDIR}/subject-info.csv"
contrast_file="${BADEDIR}/contrast-info.csv"

export INDIR="${BASEDIR}/output/${ANALYSIS_TYPE}/"
export OUTDIR="${INDIR}/group-results"
mkdir -p "${OUTDIR}/bold" "${OUTDIR}/vaso"

# loads required modules
module load matlab

# 1) SECOND-LEVEL ANALYSIS

echo "-------------------------------------------"
echo -e "\nProcessing second level analysis: GROUP\n"
echo "-------------------------------------------"

cd "${OUTDIR}"

for runtype in ${RUNTYPES[@]}; do

	echo -e "Computing ${runtype} second-level analysis...\n"
	matlab -batch " \
		addpath('${CODEDIR}'); \
		addpath(genpath('${APPDIR}')); \
		ANALYSIS_first_level('${runtype}','${contrast_file}','${subject_file}','${INDIR}','${OUTDIR}/${runtype}'); \
		exit \
	"
done

# 2) MODEL ESTIMATION

echo "-------------------------------------------"
echo -e "\nEstimating model for each contrast\n"
echo "-------------------------------------------"

for runtype in ${RUNTYPES[@]}; do

	cd "${OUTDIR}/${runtype}"

	# iterates over all existing contrasts
	for contrast in *; do

		echo -e "Estimating model for ${runtype} contrast ${contrast}\n"

		matlab -batch " \
			addpath('${CODEDIR}'); \
			addpath(genpath('${APPDIR}')); \
			ANALYSIS_estimation('${runtype}','${OUTDIR}/${runtype}/${contrast}'); \
			exit \
		"
	done
done

# 3) CONTRAST ANALYSIS

echo "-------------------------------------------"
echo -e "\nExtracting F-contrasts\n"
echo "-------------------------------------------"

for runtype in ${RUNTYPES[@]}; do

	cd "${OUTDIR}/${runtype}"

	# iterates over all existing contrasts
	for contrast in *; do

		matlab -batch " \
			addpath('${CODEDIR}'); \
			addpath(genpath('${APPDIR}')); \
			ANALYSIS_fcontrast('${runtype}','${subject_file}','${OUTDIR}/${runtype}/${contrast}'); \
			exit \
		"
	done
done

echo "*************************************"
echo "   COMPLETED SECOND LEVEL ANALYSIS!"
echo "*************************************"

