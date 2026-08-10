#!/bin/bash

# Correcting BOLD contamination

# loading required module
module load AFNI

# moving to working dir
cd /data/lavlab/layer-7t-predictive-coding/data/mri/spm/U104/func

echo "Correcting run 1"

echo "BOLD correction..."
LN_BOCO -Nulled r_sub-U104_task-bade_run-01_vaso.nii -BOLD r_sub-U104_task-bade_run-01_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii br_sub-U104_task-bade_run-01_vaso.nii

echo "Correcting mean file 1"

echo "BOLD correction..."
LN_BOCO -Nulled meansub-U104_task-bade_run-01_vaso.nii -BOLD meansub-U104_task-bade_run-01_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii bmeansub-U104_task-bade_run-01_vaso.nii

echo "Correcting run 2"

echo "BOLD correction..."
LN_BOCO -Nulled r_sub-U104_task-bade_run-02_vaso.nii -BOLD r_sub-U104_task-bade_run-02_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii br_sub-U104_task-bade_run-02_vaso.nii

echo "Correcting mean file 2"

echo "BOLD correction..."
LN_BOCO -Nulled meansub-U104_task-bade_run-02_vaso.nii -BOLD meansub-U104_task-bade_run-02_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii bmeansub-U104_task-bade_run-02_vaso.nii

echo "Correcting run 3"

echo "BOLD correction..."
LN_BOCO -Nulled r_sub-U104_task-bade_run-03_vaso.nii -BOLD r_sub-U104_task-bade_run-03_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii br_sub-U104_task-bade_run-03_vaso.nii

echo "Correcting mean file 3"

echo "BOLD correction..."
LN_BOCO -Nulled meansub-U104_task-bade_run-03_vaso.nii -BOLD meansub-U104_task-bade_run-03_bold.nii

echo "Renaming files..."
mv -v VASO_LN.nii bmeansub-U104_task-bade_run-03_vaso.nii

