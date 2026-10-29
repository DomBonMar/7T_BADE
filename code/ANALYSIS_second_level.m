function out = ANALYSIS_second_level(runtype,contrast_file,sub_file,INDIR,OUTDIR)

out = 1;

% load contrast details
CONTRAST_INFO = readcell(contrast_file);
LABELS = CONTRAST_INFO(:,1);
N_CONTRASTS = length(LABELS);

% load subject details as covariates
SUBJECT_INFO = readcell(sub_file);
SUBJECTS = SUBJECT_INFO(2:end,1);
GROUP_INFO = SUBJECT_INFO(2:end,end);
GROUPS = unique(GROUP_INFO);
COVARIATES = SUBJECT_INFO(1,2:end-1);
COVARINFO = cell2mat(SUBJECT_INFO(2:end,2:end-1));
[~,N_COVARS] = size(COVARINFO);

for g = 1:length(GROUPS)

    group = GROUPS{g}; % one analysis per group
    sub_inds = find(strcmp(GROUP_INFO,group)); % only adds correct group

    for c = 1:N_CONTRASTS
    
        CONDIR = compose("%s/%s#%s",OUTDIR,group,LABELS{c});
        mkdir(CONDIR)
        sub_files = [];
        
        % retrieves subject contrast files
        for s = 1:length(sub_inds)
            newfile = compose("%s/sub-%s/%s/con_000%d.nii",INDIR,SUBJECTS{sub_inds(s)},runtype,c);
            sub_files = [sub_files, newfile];
        end

        sub_files = sub_files(:);
    
        % specify batch
        matlabbatch{c}.spm.stats.factorial_design.dir = cellstr(CONDIR);
        matlabbatch{c}.spm.stats.factorial_design.des.mreg.scans = cellstr(sub_files);
    
        % adds model covariates
        for cov = 1:N_COVARS
            matlabbatch{c}.spm.stats.factorial_design.des.mreg.mcov(cov).c = COVARINFO(sub_inds,cov);
            matlabbatch{c}.spm.stats.factorial_design.des.mreg.mcov(cov).cname = COVARIATES{cov};
            matlabbatch{c}.spm.stats.factorial_design.des.mreg.mcov(cov).iCC = 1;
        end
    
        % other params
        matlabbatch{c}.spm.stats.factorial_design.des.mreg.incint = 1;
        matlabbatch{c}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{c}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{c}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{c}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{c}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{c}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{c}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{c}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    end

    % run batch
    spm_jobman('run',matlabbatch)
    clear matlabbatch

end

fprintf("2ND LEVEL ANALYSIS COMPLETE FOR %s RUNS\n",upper(runtype))

out = 0;

end