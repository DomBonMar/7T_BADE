#!/bin/bash

# Loading required module
module load AFNI

# Changing to anat directory
cd /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U101/anat

echo "Generating T1-like image..."
3dcalc -a /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U101/func/meansub-U101_task-bade_run-02_bold.nii -b /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U101/func/meansub-U101_task-bade_run-02_vaso.nii -expr "(a+b)/(a-b)" -datum float -prefix sub-U101_t1-like.nii -overwrite