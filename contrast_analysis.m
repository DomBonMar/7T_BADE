function matlabbatch = contrast_analysis(CONTRASTS,LABELS,OUTDIR)

% output dir containing SPM.mat file
matlabbatch{1}.spm.stats.con.spmmat = {sprintf('%s/SPM.mat',OUTDIR)};

% adds one array per contrast
for c = 1:length(CONTRASTS)
    matlabbatch{1}.spm.stats.con.consess{c}.tcon.name = LABELS{c};
    matlabbatch{1}.spm.stats.con.consess{c}.tcon.weights = CONTRASTS{c};
    matlabbatch{1}.spm.stats.con.consess{c}.tcon.sessrep = 'none';
end

matlabbatch{1}.spm.stats.con.delete = 0;

end