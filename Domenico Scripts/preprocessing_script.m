% 7T fMRI - Preprocessing Script
% By domenico

% general info on scan
BASEDIR = '/data/lavlab/layer-7t-predictive-coding/';

sub = 'pilot03';

DATADIR = [BASEDIR, 'data/', sub,'/nifti/']; % nifti folder
cd(DATADIR)

BATCHDIR = [BASEDIR, sub, '/'] % to fix... find place for batch files

SPMDIR = '/home/cic/mardom/Documents/APPS/spm/';
addpath(SPMDIR);


% links to folder struct
types = {'bold', 'vaso'};

bold_runs = ["ilot03_rslh_ep3d_vaso_Trials1_E00_S00_M_7.nii",...
    "pilot03_rslh_ep3d_vaso_Trials2_E00_S00_M_9.nii",...
    "pilot03_rslh_ep3d_vaso_Trials3_E00_S00_M_11.nii"];
vaso_runs = ["pilot03_rslh_ep3d_vaso_Trials1_E00_S01_M_8.nii",...
    "pilot03_rslh_ep3d_vaso_Trials2_E00_S01_M_10.nii",...
    "pilot03_rslh_ep3d_vaso_Trials3_E00_S01_M_12.nii"];
all_runs = [bold_runs,vaso_runs];

anat_img = "pilot03_anat-T1w_acq-mp2rage_05mm_UP_UNI_Images_18.nii";

%% Motion Correction

% iterate through runs
i = 1;
for run = all_runs

    matlabbatch{i}.spm.spatial.realign.estwrite.data = {sprintf("%s%s",DATADIR,run)};
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.quality = 0.95;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.sep = 1.5;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.fwhm = 1;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

    i = 1 + i;

end

save preprocessing_batch matlabbatch
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

%% Coregistration

i = 1;
for run = all_runs

    % anat file
    matlabbatch{i}.spm.spatial.coreg.estimate.ref = {sprintf("%s%s",DATADIR,anat_img)};
    % mean file
    matlabbatch{i}.spm.spatial.coreg.estimate.source = {sprintf("%smean%s",DATADIR,run)};
    % realigned func file
    matlabbatch{i}.spm.spatial.coreg.estimate.other = {sprintf("%sr%s",DATADIR,run)};
    matlabbatch{i}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{i}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{i}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{i}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    i = 1 + i;

end

save preprocessing_batch matlabbatch
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

%% Correct T2* Dependency

% check command line -> do steps there

%% Segmentation

% anat scan
matlabbatch{1}.spm.spatial.preproc.channel.vols = {sprintf("%s%s",DATADIR,anat_img)};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {sprintf("%stpm/TPM.nii,1",SPMDIR)};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {sprintf("%stpm/TPM.nii,2",SPMDIR)};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {sprintf("%stpm/TPM.nii,3",SPMDIR)};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {sprintf("%stpm/TPM.nii,4",SPMDIR)};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {sprintf("%stpm/TPM.nii,5",SPMDIR)};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {sprintf("%stpm/TPM.nii,6",SPMDIR)};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0 0.1 0.01 0.04];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];

save preprocessing_batch matlabbatch
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

%% Normalization

% deformation field (y_ file)
matlabbatch{1}.spm.spatial.normalise.write.subj.def = {sprintf("%sy_%s",DATADIR,anat_img)};
% list of realigned func (r files)
r_runs = [];
for run = all_runs
    r_runs = [r_runs, sprintf("%sr%s",DATADIR,run)];
end
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {r_runs};
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

save preprocessing_batch matlabbatch
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

%% Smoothing

% list of func (wr files)
wr_runs = [];
for run = all_runs
    wr_runs = [wr_runs, sprintf("%swr%s",DATADIR,run)];
end
matlabbatch{1}.spm.spatial.smooth.data = {wr_runs};
matlabbatch{1}.spm.spatial.smooth.fwhm = [2 2 2];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

save preprocessing_batch matlabbatch
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch
