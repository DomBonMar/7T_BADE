#!/bin/bash

# Converting dicom to nifti for U101

module load dcm2niix
module load dcm2bids

dcm2bids -d /data/lavlab/layer-7t-predictive-coding/data/mri/dicom/U101 -p U101 -c /data/lavlab/layer-7t-predictive-coding/code/bids-config.json -o /data/lavlab/layer-7t-predictive-coding/data/mri/bids