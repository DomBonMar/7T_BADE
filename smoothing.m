function matlabbatch = smoothing(runs,FUNCDIR,SPMDIR)

% generates coregistration batch using SPM

% runs >> array containing filenames of all functional runs
% FUNCDIR >> folder with functional scans

addpath(SPMDIR);

% list of func (wr files)
wr_runs = cell(length(runs),1);
for i = 1:length(runs)

    % if vaso, needs to select corrected run
    if i > length(bold_runs)
        tag = "c";
    else
        tag = "";
    end

    wr_runs{i} = sprintf('%s/w%sr_%s',FUNCDIR,tag,runs(i));
end

matlabbatch{1}.spm.spatial.smooth.data = wr_runs;
matlabbatch{1}.spm.spatial.smooth.fwhm = [2 2 2];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

end