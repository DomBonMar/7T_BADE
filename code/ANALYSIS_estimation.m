function out = ANALYSIS_estimation(runtype,OUTDIR)

out = 1;

% MODEL ESTIMATION

matlabbatch{1}.spm.stats.fmri_est.spmmat = {sprintf('%s/SPM.mat',OUTDIR)};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

fprintf("MODEL ESTIMATION COMPLETE FOR %s RUNS\n",upper(runtype))

out = 0;

end