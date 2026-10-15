#!/bin/bash

# only run when in baseline repo directory

BASEDIR=$(pwd)

mkdir -p data/dicom
mkdir -p data/bids
mkdir -p data/processed
mkdir -p data/bade_fmri_task
mkdir -p output/functional
mkdir -p output/layer
mkdir software

# prepare virtual env for dcm2bids
module load python

virtualenv --no-download $BASEDIR/dcm2bids_env
source ${BASEDIR}/dcm2bids_env/bin/activate
pip install --no-index --upgrade pip
pip install dcm2bids --no-index

module unload python
