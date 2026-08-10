#~/bin/bash

# Load required module
module load FSL

# realigns runs
REF=/data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot03/func/cr_sub-pilot03_task-bade_run-03_bold.nii

fslcpgeom "$REF" /data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot03/func/cr_sub-pilot03_task-bade_run-01_bold.nii

fslcpgeom "$REF" /data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot03/func/cr_sub-pilot03_task-bade_run-02_bold.nii

