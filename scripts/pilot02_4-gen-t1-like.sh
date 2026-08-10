#!/bin/bash

# Loading required module
module load AFNI

# Changing to anat directory
cd /data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot02/anat

echo "Generating T1-like image..."
3dcalc -a /data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot02/func/meansub-pilot02_task-bade_run-03_bold.nii -b /data/lavlab/layer-7t-predictive-coding/data/mri/spm/pilot02/func/meansub-pilot02_task-bade_run-03_vaso.nii -expr "(a+b)/(a-b)" -datum float -prefix sub-pilot02_t1-like-bold.nii -overwrite

echo "Saving bold/vaso copies..."
cp sub-pilot02_t1-like-bold.nii sub-pilot02_t1-like-vaso.nii