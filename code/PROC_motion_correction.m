function out = PROC_motion_correction(runs,runtype,INDIR,OUTDIR,INFIX,PREFIX)

% runs >> array containing filenames of all functional runs

out = 1;
n_runs = 0;

cd(OUTDIR)

fprintf("\nRunning on %s runs\n",runtype)

% preparing batch
for r = 1:length(runs)

    % checks if output already generated
    if isfile(compose("%s/moco-%s",OUTDIR,runs(r)))
	    fprintf('Skipping: file %d already computed.\n',r)
	    continue;
    end

    % else >> adds to batch
    n_runs = n_runs + 1;
    run = sprintf('%s/%s%s',INDIR,INFIX,runs(r));

    matlabbatch{r}.spm.spatial.realign.estwrite.data = {cellstr(run)};
    matlabbatch{r}.spm.spatial.realign.estwrite.eoptions.quality = 0.95;
    matlabbatch{r}.spm.spatial.realign.estwrite.eoptions.sep = 1.5;
    matlabbatch{r}.spm.spatial.realign.estwrite.eoptions.fwhm = 1;
    matlabbatch{r}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{r}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{r}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{r}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{r}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{r}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{r}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{r}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{r}.spm.spatial.realign.estwrite.roptions.prefix = PREFIX;

end

% running process

if n_runs ~= 0
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch
end

fprintf("MOTION CORRECTION COMPLETED for %s\n", runtype)

% move images
system(compose("rename '%s%s' '%s' * ",PREFIX,INFIX,PREFIX))

% REALIGN IMAGES (nordic and moco)

fprintf("Realigning %s runs...\n",runtype)
for r = 1:length(runs)

    % nordic alignment
    run = sprintf('%s/%s%s',INDIR,PREFIX,runs(r));
    target = sprintf('%s/%s%s',INDIR,INFIX,runs(r));

    fprintf("Target aligned from NORDIC is:\n")
    M = spm_get_space(target) % target alignment
    
    % moco correction algnment
    fprintf("MOCO alignment pre-adjustment is:\n")
    spm_get_space(run)
    V = spm_vol(run)

    fprintf("Realigning %s run %s as %s\n",runtype,run,target)
    for n = 1:numel(V)
        fprintf("Alignment for volume %d is:\n",n)
        spm_get_space(sprintf('%s,%d',run,n), M);
    end

    fprintf("MOCO alignment after adjustment is:\n")
    spm_get_space(run)
end

out = 0;

end