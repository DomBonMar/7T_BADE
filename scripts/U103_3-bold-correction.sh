#!/bin/bash

# Correcting BOLD contamination for U103

# loading required module
module load AFNI

# moving to working dir
cd /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U103/func

echo "Correcting run 1"

echo "BOLD correction..."
LN_BOCO -Nulled r_sub-U103_task-bade_run-01_vaso.nii -BOLD r_sub-U103_task-bade_run-01_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii br_sub-U103_task-bade_run-01_vaso.nii

echo "Correcting mean file 1"

echo "BOLD correction..."
LN_BOCO -Nulled meansub-U103_task-bade_run-01_vaso.nii -BOLD meansub-U103_task-bade_run-01_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii bmeansub-U103_task-bade_run-01_vaso.nii

echo "Correcting run 2"

echo "BOLD correction..."
LN_BOCO -Nulled r_sub-U103_task-bade_run-02_vaso.nii -BOLD r_sub-U103_task-bade_run-02_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii br_sub-U103_task-bade_run-02_vaso.nii

echo "Correcting mean file 2"

echo "BOLD correction..."
LN_BOCO -Nulled meansub-U103_task-bade_run-02_vaso.nii -BOLD meansub-U103_task-bade_run-02_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii bmeansub-U103_task-bade_run-02_vaso.nii

echo "Correcting run 3"

echo "BOLD correction..."
LN_BOCO -Nulled r_sub-U103_task-bade_run-03_vaso.nii -BOLD r_sub-U103_task-bade_run-03_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii br_sub-U103_task-bade_run-03_vaso.nii

echo "Correcting mean file 3"

echo "BOLD correction..."
LN_BOCO -Nulled meansub-U103_task-bade_run-03_vaso.nii -BOLD meansub-U103_task-bade_run-03_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii bmeansub-U103_task-bade_run-03_vaso.nii

