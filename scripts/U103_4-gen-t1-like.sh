#!/bin/bash

# Loading required module
module load AFNI

# Changing to anat directory
cd /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U103/anat

echo "Generating T1-like image..."
3dcalc -a /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U103/func/meansub-U103_task-bade_run-03_bold.nii -b /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U103/func/meansub-U103_task-bade_run-03_vaso.nii -expr "(a+b)/(a-b)" -datum float -prefix sub-U103_t1-like.nii -overwrite