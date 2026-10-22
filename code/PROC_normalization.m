function out = PROC_normalization(runs,runtype,ANATDIR,FUNCDIR,INFIX,PREFIX)

% runs >> array containing filenames of all functional runs
% ANATDIR >> folder with anatomical scans
% FUNCDIR >> folder with functional scans

out = 1;
n = 0;
fprintf("Running normalization on %s runs\n",runtype)

N_RUNS = length(runs);

for r = 1:2*N_RUNS

    ind = mod(r,N_RUNS);
    if ind == 0
        ind = N_RUNS;
    end
    % normalizes the functional runs and the anat templates per run
    if r <= N_RUNS
        outfile = compose("%s/%s%s",FUNCDIR,PREFIX,runs(ind));
        infile = compose("%s/%s%s",FUNCDIR,INFIX,runs(ind));
    else
        outfile = compose("%s/%smanat-%s",ANATDIR,PREFIX,runs(ind));
        infile = compose("%s/manat-%s",ANATDIR,runs(ind));
    end

    % checks if output already generated
    if isfile(outfile)
	    fprintf('Skipping: file %s already computed.\n',outfile)
	    continue;
    end

    % else >> adds to batch
    n = n + 1;
    warpfile = compose("%s/y_anat-%s",ANATDIR,runs(ind));

    % deformation field (y_ file)
    matlabbatch{n}.spm.spatial.normalise.write.subj.def = cellstr(warpfile);
    % realigned func run
    matlabbatch{n}.spm.spatial.normalise.write.subj.resample = cellstr(infile);
    % other params
    matlabbatch{n}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70                                                        
        78 76 85];
    matlabbatch{n}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{n}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{n}.spm.spatial.normalise.write.woptions.prefix = PREFIX;

end

% also normalizes the anat template


if n ~= 0
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch
end

fprintf("NORMALIZATION COMPLETED for %s runs.\n",runtype)
out = 0;

end