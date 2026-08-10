% 7T fMRI - first level analysis script
% by Domenico

% lists directories
BASEDIR = '/data/lavlab/layer-7t-predictive-coding';
SPMDIR = '/home/cic/mardom/Documents/APPS/spm';
addpath(SPMDIR);
CODEDIR = sprintf('%scode/',BASEDIR);
addpath(CODEDIR);

% scan info
SUB = 'pilot03';
TR = 8.140; % in seconds

% locates / creates relevant file directories
DATADIR = sprintf('%s/data/%s/nifti/',BASEDIR,SUB); % nifti folder
FUNCDIR = sprintf('%s/func/',DATADIR);
ANATDIR = sprintf('%s/anat/',DATADIR);

FLADIR = sprintf('%s/FLA_funcvaso/',DATADIR); % for testing
mkdir(FLADIR)
cd(FLADIR)

BATCHDIR = sprintf('%sbatchfiles/',DATADIR);

% retrieves subject images
[bold_runs, vaso_runs, anat_img] = get_images(SUB,FUNCDIR,ANATDIR,false);

% pick desired run type
TYPE = "bold";
all_runs = eval(sprintf('%s_runs',TYPE));
% all_runs = vaso_runs([2,3]);

%% Generate Timing Vectors

% reads timing vector files

N_RUNS = length(all_runs);
CONDITIONS = ["confirm", "disconfirm","baseline"];
DURATIONS = [9.5,9.5,24];

timing_file = sprintf("%s%s_timing_vectors.mat",CODEDIR,SUB);
timings = load(timing_file);

% use data.{SUB}_run{X}_{condition} to index the timing vectors

reduceBy = 1; % testing for Jeanne

% merge all the data across 3 conditions
for cond = CONDITIONS
    full_data.(cond) = [];
    for run = 1:N_RUNS
        label = sprintf("%s_run%d_%s",SUB,run,cond);
        tps = timings.(label);
        ntim = length(timings.(label));
        timings.(label) = timings.(label)(1:ntim*reduceBy);
        % timings.(label) = randsample(timings.(label),ntim*reduceBy); % random selection
        full_data.(cond) = horzcat(full_data.(cond),tps);
    end
end

%% First-level Analysis

% main FLA setup
matlabbatch{1}.spm.stats.fmri_spec.dir = {FLADIR};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for run = 1:N_RUNS

    % locates run file
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = {sprintf('%sswr%s',FUNCDIR,all_runs(run))};

    for c = 1:length(CONDITIONS)
        % adds timing data per condition
        label = sprintf("%s_run%d_%s",SUB,run,CONDITIONS(c));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).name = char(CONDITIONS(c));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).onset = timings.(label);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).duration = DURATIONS(c);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).orth = 1;
    end

    % addditional run parameters
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress = struct('name', {}, 'val', {});
    [~,filename,~] = fileparts(all_runs(run));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg = {sprintf('%srp_%s.txt',FUNCDIR,filename)};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf = 128;
end

% global regression parameters
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

cd(BATCHDIR)
save FLA_batch matlabbatch
cd(FLADIR)
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

%% Model Estimation

matlabbatch{1}.spm.stats.fmri_est.spmmat = {sprintf('%sSPM.mat',FLADIR)};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

cd(BATCHDIR)
save ME_batch matlabbatch
cd(FLADIR)
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

% contrast vectors to copy
% runs 1-2:
% C-B[1 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 -1 0 0 0 0 0 0 0 0 0]
% D-B[0 0 1 0 -1 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0]
% D-C[-1 0 1 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 0 0 0]


% runs 1-2-3:
% C-B[1 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 -1 0 0 0 0 0 0 0 0 0 0]
% D-B[0 0 1 0 -1 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0]
% D-C[-1 0 1 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 0 0 0 0]

