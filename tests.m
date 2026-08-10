% testing script

sub = 'pilot02';

N_RUNS = 3;
RUN_TYPES = ["bold", "vaso"];

% baseline directories
BASEDIR = '/data/lavlab/layer-7t-predictive-coding';
DATADIR = sprintf('%s/data',BASEDIR);

% software + code
CODEDIR = sprintf('%s/code',BASEDIR);
addpath(CODEDIR);
SPMDIR = '/home/cic/mardom/Documents/APPS/spm/';
addpath(SPMDIR);


% raw data directories for sub
DICOM = sprintf('%s/mri/dicom/%s',DATADIR,sub);
BIDS = sprintf('%s/mri/bids',DATADIR);
SUBBIDS = sprintf('%s/sub-%s',BIDS,sub);

% processed data directories for sub
SPM = sprintf('%s/mri/spm/%s',DATADIR,sub);
FUNCDIR = sprintf('%s/func',SPM);
ANATDIR = sprintf('%s/anat',SPM);
SCRIPTS = sprintf('%s/scripts',CODEDIR);

% analysis dirs
OUTDIR = sprintf('%s/unpublished-results/%s',BASEDIR,'bold');
FLADIR = sprintf('%s/first-level-analysis/sub-%s',OUTDIR,sub);
UPDIR = sprintf('%s/upsampled/sub-%s',OUTDIR,sub);
MASKDIR = sprintf('%s/layer-masks/sub-%s',OUTDIR,sub);

[bold_runs, vaso_runs, anat_img] = get_images(sub,SUBBIDS);

all_runs = [bold_runs,vaso_runs];

%%



M1 = spm_get_space(sprintf('%s/cr_%s',FUNCDIR,all_runs{1}));
M2 = spm_get_space(sprintf('%s/cr_%s',FUNCDIR,all_runs{2}));
M3 = spm_get_space(sprintf('%s/cr_%s',FUNCDIR,all_runs{3}));
M4 = spm_get_space(sprintf('%s/cbr_%s',FUNCDIR,all_runs{4}));
M5 = spm_get_space(sprintf('%s/cbr_%s',FUNCDIR,all_runs{5}));
M6 = spm_get_space(sprintf('%s/cbr_%s',FUNCDIR,all_runs{6}));

t1like = spm_get_space(sprintf('%s/csub-%s_t1-like-bold.nii',ANATDIR,sub));
upt1 = spm_get_space(sprintf('%s/Up_csub-%s_t1-like-bold.nii',ANATDIR,sub));
upt12 = spm_get_space(sprintf('%s/Up_csub-%s_t1-like-vaso.nii',ANATDIR,sub));

spmT1 = spm_get_space(sprintf('%s/spmT_0001.nii',FLADIR));
upst1 = spm_get_space(sprintf('%s/Up_spmT_0001.nii',FLADIR));

% for i = 1:numel(all_runs)
%     V = spm_vol(all_runs{i});         
%     for n = 1:numel(V)
%         spm_get_space([all_runs{i} ',' num2str(n)], M);   
%     end
% end