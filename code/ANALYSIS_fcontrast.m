function out = ANALYSIS_fcontrast(runtype,sub_file,OUTDIR)

% runtype: type of fmri data (bold or vaso)
% OUTDIR: directory where the results will be written

out = 1;
cd(OUTDIR);

% if vaso --> invert contrast [DO WE STILL NEED THIS?]

% computes number of covariates
SUBJECT_INFO = readcell(sub_file);
COVARINFO = cell2mat(SUBJECT_INFO(2:end,2:end-1));
[~,N_COVARS] = size(COVARINFO);

% generates contrast arrays
tcon = zeros(1,N_COVARS+1); tcon(1) = 1; % MAIN EFFECT
fcon = zeros(N_COVARS,N_COVARS+1);
for c = 1:N_COVARS
    fcon(c,c+1) = 1;
end

% output dir containing SPM.mat file
matlabbatch{1}.spm.stats.con.spmmat = cellstr(compose("%s/SPM.mat",OUTDIR));

% adds one contrast for main effects
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = "Main";
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = tcon;
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

% adds one contrast for covariate effects
matlabbatch{1}.spm.stats.con.consess{2}.fcon.name = "Covariates";
matlabbatch{1}.spm.stats.con.consess{2}.fcon.weights = fcon;
matlabbatch{1}.spm.stats.con.consess{2}.fcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.delete = 0;

spm_jobman('run',matlabbatch)
clear matlabbatch

fprintf("CONTRAST ANALYSIS COMPLETE FOR %s RUNS\n",upper(runtype))

out = 0;

end