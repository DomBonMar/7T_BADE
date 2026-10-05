function matlabbatch = first_level_analysis(runs,moco_files,timings,idx_labels,TR,DURATIONS,CONDITIONS,OUTDIR)

% main FLA setup
matlabbatch{1}.spm.stats.fmri_spec.dir = {OUTDIR};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for i = 1:length(runs)

    % locates run file
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans = cellstr(runs(i));

    for c = 1:length(CONDITIONS)
        % adds timing data per condition
        label = idx_labels(i,c);
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(c).name = char(CONDITIONS(c));
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(c).onset = timings.(label);
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(c).duration = DURATIONS(c);
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(c).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(c).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(c).orth = 1;
    end

    % addditional run parameters
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi_reg = cellstr(moco_files(i));
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).hpf = 128;
end

% global regression parameters
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';


end