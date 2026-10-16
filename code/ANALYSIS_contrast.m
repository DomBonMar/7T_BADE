function out = ANALYSIS_contrast(runtype,contrast_file,OUTDIR)

% runtype: type of fmri data (bold or vaso)
% contrast_file: contains contrast labels and weights
% OUTDIR: directory where the results will be written

out = 1;
cd(OUTDIR);

% load contrast information
CONTRAST_INFO = readcell(contrast_file);
CONTRASTS = cell2mat(CONTRAST_INFO(:,2:end));
LABELS = CONTRAST_INFO(:,1);

% if vaso --> invert contrast
if strcmpi(runtype,'vaso')
    CONTRASTS = CONTRASTS * -1;
end

% output dir containing SPM.mat file
matlabbatch{1}.spm.stats.con.spmmat = cellstr(compose("%s/SPM.mat",OUTDIR));

% adds one array per contrast
for c = 1:length(LABELS)
    matlabbatch{1}.spm.stats.con.consess{c}.tcon.name = LABELS{c};
    matlabbatch{1}.spm.stats.con.consess{c}.tcon.weights = CONTRASTS(c,:);
    matlabbatch{1}.spm.stats.con.consess{c}.tcon.sessrep = 'none';
end

matlabbatch{1}.spm.stats.con.delete = 0;

spm_jobman('run',matlabbatch)
clear matlabbatch

fprintf("CONTRAST ANALYSIS COMPLETE FOR %s RUNS\n",upper(runtype))

out = 0;

end