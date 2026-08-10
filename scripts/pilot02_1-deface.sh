#!/bin/bash

# Defacing anatomical scans for pilot02

# Loading required modules
module load python
module load FSL

# Changing working dir
cd /data/lavlab/layer-7t-predictive-coding/data/mri/bids/sub-pilot02/anat

scan=$(ls ./*T1map.nii)
pydeface $scan

scan=$(ls ./*UNIT1.nii)
pydeface $scan

scan=$(ls ./*INV1.nii)
pydeface $scan

scan=$(ls ./*INV2.nii)
pydeface $scan