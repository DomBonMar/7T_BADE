#!/bin/bash

# Loading required module
module load AFNI

# Changing to anat directory
cd /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U102/anat

echo "Generating T1-like image..."
3dcalc -a /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U102/func/meansub-U102_task-bade_run-03_bold.nii -b /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U102/func/meansub-U102_task-bade_run-03_vaso.nii -expr "(a+b)/(a-b)" -datum float -prefix sub-U102_t1-like.nii -overwrite