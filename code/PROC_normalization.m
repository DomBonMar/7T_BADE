function out = PROC_normalization(runs,runtype,anat_img,ANATDIR,FUNCDIR,INFIX,PREFIX)

% runs >> array containing filenames of all functional runs
% ANATDIR >> folder with anatomical scans
% FUNCDIR >> folder with functional scans

out = 1;
n_runs = 0;
fprintf("Running normalization on %s runs\n",runtype)

for r = 1:length(runs)

    % checks if output already generated
    if isfile(compose("%s/%s%s",FUNCDIR,PREFIX,runs(r)))
	    fprintf('Skipping: file %s already computed.\n',runs(r))
	    continue;
    end

    % else >> adds to batch
    n_runs = n_runs + 1;
    warpfile = cellstr(compose("%s/y_%s",ANATDIR,anat_img));
    run = cellstr(compose("%s/%s%s",FUNCDIR,INFIX,runs(r)));

    % deformation field (y_ file)
    matlabbatch{r}.spm.spatial.normalise.write.subj.def = warpfile;
    % realigned func run
    matlabbatch{r}.spm.spatial.normalise.write.subj.resample = run;
    % other params
    matlabbatch{r}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70                                                        
        78 76 85];
    matlabbatch{r}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{r}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{r}.spm.spatial.normalise.write.woptions.prefix = PREFIX;

end

if n_runs ~= 0
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch
end

fprintf("NORMALIZATION COMPLETED for %s runs.\n",runtype)
out = 0;

end