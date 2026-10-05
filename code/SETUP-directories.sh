#!/bin/bash

# only run when in baseline repo directory

BASEDIR=$(pwd)

mkdir -p data/dicom
mkdir -p data/bids
mkdir -p data/processed
mkdir -p data/bade_fmri_task
mkdir software

# prepare virtual env for dcm2bids
module load python

virtualenv --no-dowload $BASEDIR/dcm2bids_env
source ${BASEDIR}/dcm2bids_env/bin/activate
pip install --no-index --upgrade pip
pip install dcm2bids --no-index

module unload python
