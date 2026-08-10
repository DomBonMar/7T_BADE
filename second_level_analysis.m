% Second-level analysis
% grouping data from all subjects

% metadata
SUBS = {'U101','U102','U103','U104'};
CONTRASTS = {'Confirm - Baseline', 'Disconfirm - Baseline', 'Disconfirm - Confirm'};
ROIS = {'VC','ACC'};
NUM_LAYERS = 10;

% relevant directories
BASEDIR = '/data/lavlab/layer-7t-predictive-coding';
CODEDIR = sprintf('%s/code',BASEDIR);
DATADIR = sprintf('%s/data',BASEDIR);
addpath(genpath(CODEDIR));

% processed data directories for sub
SPMDIR = sprintf('%s/mri/spm/%s',DATADIR,sub);
FUNCDIR = sprintf('%s/func',SPMDIR);
ANATDIR = sprintf('%s/anat',SPMDIR);

