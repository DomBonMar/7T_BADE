#!/bin/bash

# Loading required module
module load AFNI

# Changing to anat directory
cd /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U104/anat

echo "Generating T1-like image..."
3dcalc -a /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U104/func/meansub-U104_task-bade_run-01_bold.nii -b /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U104/func/meansub-U104_task-bade_run-01_vaso.nii -expr "(a+b)/(a-b)" -datum float -prefix sub-U104_t1-like.nii -overwrite