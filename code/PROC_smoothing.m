function out = PROC_smoothing(runs,runtype,FUNCDIR,INFIX,PREFIX)

% runs >> array containing filenames of all functional runs
% FUNCDIR >> folder with functional scans

out = 1;
n = 0;
fprintf("Running smoothing on %s runs\n",runtype)

% list of func (wr files)
run_array = [];
for r = 1:length(runs)

    % checks if output already generated
    if isfile(compose("%s/%s%s",FUNCDIR,PREFIX,runs(r)))
	    fprintf('Skipping: file %s already computed.\n',runs(r))
	    continue;
    end

    % else >> adds to batch
    n = n + 1;
    run = compose("%s/%s%s",FUNCDIR,INFIX,runs(r));
    run_array = [run_array, run];

end

run_array = cellstr(run_array);
run_array = run_array(:); % convert to column cellstr

matlabbatch{1}.spm.spatial.smooth.data = run_array;
matlabbatch{1}.spm.spatial.smooth.fwhm = [2 2 2];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = PREFIX;

if n ~= 0
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch
end

fprintf("SMOOTHING COMPLETED for %s runs.\n",runtype)
out = 0;

end