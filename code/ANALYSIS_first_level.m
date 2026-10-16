function out = ANALYSIS_first_level(sub,runs,runtype,TR,condition_file,INDIR,INFIX,timing_file,OUTDIR)

% sub: truncated id with "sub-" prefix
% runs: list of fmri data runs
% runtype: type of fmri data (bold or vaso)
% TR: repetition time of the experiment
% DURATIONS: duration (in sec) of each experimental condition
% CONDITIONS: list of labels for each experimental condition
% INDIR: data directory containing input runs
% INFIX: input prefix of the input runs
% timing_file: contains bade task timing information
% OUTDIR: directory where the results will be written

out = 1;
cd(OUTDIR);

% converts metadata to matlab types
CONDITION_INFO = readcell(condition_file);
CONDITIONS = CONDITION_INFO(:,1);
DURATIONS = CONDITION_INFO(:,2);
TR = str2double(TR);

% loads timing vector info
timings = load(timing_file);

% use timings.{SUB}_run{X}_{condition} to index the timing vectors

% main FLA setup
matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(OUTDIR);
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for r = 1:length(runs)

    % locates run file info
    run = compose("%s/%s%s",INDIR,INFIX,runs(r));
    [~,run_stem,~] = fileparts(run);
    moco_file = sprintf('%s/rp_%s.txt',INDIR,run_stem);

    matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = cellstr(run);

    for c = 1:length(CONDITIONS)

        % adds timing data per condition
        idx_label = compose("%s_run%d_%s",sub,r,lower(CONDITIONS{c}));
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = char(CONDITIONS{c});
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = timings.(idx_label);
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = DURATIONS{c};
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).orth = 1;
    end

    % addditional run parameters
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = cellstr(moco_file);
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = 128;
end

% global regression parameters
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

cd(OUTDIR)
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

disp("FIRST-LEVEL ANALYSIS COMPLETE FOR %s RUNS\n",upper(runtype))

% MODEL ESTIMATION

matlabbatch{1}.spm.stats.fmri_est.spmmat = {sprintf('%s/SPM.mat',OUTDIR)};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

disp("MODEL ESTIMATION COMPLETE FOR %s RUNS\n",upper(runtype))

out = 0;

end