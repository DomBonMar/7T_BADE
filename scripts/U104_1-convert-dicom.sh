#!/bin/bash

# Converting dicom to nifti for U104

module load dcm2niix
module load dcm2bids

dcm2bids -d /data/lavlab/layer-7t-predictive-coding/data/mri/dicom/U104 -p U104 -c /data/lavlab/layer-7t-predictive-coding/code/bids-config.json -o /data/lavlab/layer-7t-predictive-coding/data/mri/bids