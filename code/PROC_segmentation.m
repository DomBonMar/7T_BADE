function out = PROC_segmentation(runs,runtype,ANATDIR,SPMDIR)

% runs >> array containing filenames of all functional runs
% ANATDIR >> folder with anatomical scans

out = 1;
n_runs = 0;

for r = 1:length(runs)

    % checks if output already generated
    if isfile(compose("%s/y_anat-%s",ANATDIR,runs(r)))
        fprintf('Skipping: segmentation already complete.\n')
        return
    end

    n_runs = n_runs + 1;
    anatfile = compose("%s/anat-%s",ANATDIR,runs(r));

    % anat scans per run
    matlabbatch{r}.spm.spatial.preproc.channel.vols = cellstr(anatfile);
    matlabbatch{r}.spm.spatial.preproc.channel.biasreg = 0.0001;
    matlabbatch{r}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{r}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{r}.spm.spatial.preproc.tissue(1).tpm = {sprintf('%s/tpm/TPM.nii,1',SPMDIR)};
    matlabbatch{r}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{r}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(2).tpm = {sprintf('%s/tpm/TPM.nii,2',SPMDIR)};
    matlabbatch{r}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{r}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(3).tpm = {sprintf('%s/tpm/TPM.nii,3',SPMDIR)};
    matlabbatch{r}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{r}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(4).tpm = {sprintf('%s/tpm/TPM.nii,4',SPMDIR)};
    matlabbatch{r}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{r}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(5).tpm = {sprintf('%s/tpm/TPM.nii,5',SPMDIR)};
    matlabbatch{r}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{r}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(6).tpm = {sprintf('%s/tpm/TPM.nii,6',SPMDIR)};
    matlabbatch{r}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{r}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{r}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{r}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{r}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{r}.spm.spatial.preproc.warp.reg = [0 0 0.1 0.01 0.04];
    matlabbatch{r}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{r}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{r}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{r}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{r}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{r}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];

end

if n_runs ~= 0
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch
end

fprintf("SEGMENTATION COMPLETED FOR %s RUNS\n",upper(runtype))
out = 0;

end