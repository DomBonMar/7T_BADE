function matlabbatch = segmentation(runs,ANATDIR,SPMDIR)

% generates segmentation batch using SPM

% runs >> array containing filenames of all functional runs
% ANATDIR >> folder with anatomical scans

addpath(SPMDIR);

for i = 1:length(runs)

    % anat scans per run
    matlabbatch{i}.spm.spatial.preproc.channel.vols = {sprintf('%s/anat-%s',ANATDIR,runs(i))};
    matlabbatch{i}.spm.spatial.preproc.channel.biasreg = 0.0001;
    matlabbatch{i}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{i}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{i}.spm.spatial.preproc.tissue(1).tpm = {sprintf('%s/tpm/TPM.nii,1',SPMDIR)};
    matlabbatch{i}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{i}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(2).tpm = {sprintf('%s/tpm/TPM.nii,2',SPMDIR)};
    matlabbatch{i}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{i}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(3).tpm = {sprintf('%s/tpm/TPM.nii,3',SPMDIR)};
    matlabbatch{i}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{i}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(4).tpm = {sprintf('%s/tpm/TPM.nii,4',SPMDIR)};
    matlabbatch{i}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{i}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(5).tpm = {sprintf('%s/tpm/TPM.nii,5',SPMDIR)};
    matlabbatch{i}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{i}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(6).tpm = {sprintf('%s/tpm/TPM.nii,6',SPMDIR)};
    matlabbatch{i}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{i}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{i}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{i}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{i}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{i}.spm.spatial.preproc.warp.reg = [0 0 0.1 0.01 0.04];
    matlabbatch{i}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{i}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{i}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{i}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{i}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{i}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
end


end