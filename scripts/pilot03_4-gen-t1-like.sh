#!/bin/bash

# Loading required module
module load AFNI

# Changing to anat directory
cd /data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot03/anat

echo "Generating T1-like image..."
3dcalc -a /data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot03/func/meansub-pilot03_task-bade_run-03_bold.nii -b /data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot03/func/meansub-pilot03_task-bade_run-03_vaso.nii -expr "(a+b)/(a-b)" -datum float -prefix sub-pilot03_t1-like.nii -overwrite