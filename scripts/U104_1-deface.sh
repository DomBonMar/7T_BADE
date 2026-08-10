#!/bin/bash

# Defacing anatomical scans for U104

# Loading required modules
module load python
module load FSL

# Changing working dir
cd /data/lavlab/layer-7t-predictive-coding/data/mri/bids/sub-U104/anat

scan=$(ls ./*T1map.nii)
echo "Defacing T1map..."
pydeface $scan

scan=$(ls ./*UNIT1.nii)
echo "Defacing UNIT1..."
pydeface $scan

scan=$(ls ./*INV1.nii)
echo "Defacing INV1..."
pydeface $scan

scan=$(ls ./*INV2.nii)
echo "Defacing INV2..."
pydeface $scan