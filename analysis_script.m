% 7T fMRI - first level analysis script
% by Domenico

%% 0.1) SCAN INFO AND METADATA

sub = 'U103';
first_run = true;

% finding repetition time (nifti metadata)
TR = 8.140; % in seconds

RUN_TYPE = "bold";
CONDITIONS = ["confirm", "disconfirm","baseline"];
DURATIONS = [9,9,24];

% gets file tag for functional runs
% BOLD RUNS
 if strcmp(RUN_TYPE,'bold')
    tag = 'cr';
% VASO RUNS
elseif strcmp(RUN_TYPE,'vaso')
    tag = 'cbr';
else
     tag = 'errorerror';
 end

%% 0.2) FILE DIRECTORY SETUP

% data directories
BASEDIR = '/data/lavlab/layer-7t-predictive-coding';
DATADIR = sprintf('%s/data',BASEDIR); % nifti folder
SUBBIDS = sprintf('%s/mri/bids/sub-%s',DATADIR,sub);

% processed data directories
SPM = sprintf('%s/mri/spm/%s',DATADIR,sub);
FUNCDIR = sprintf('%s/func',SPM);
ANATDIR = sprintf('%s/anat',SPM);

% software + code
SPMDIR = '/home/cic/mardom/Documents/APPS/spm';
CODEDIR = sprintf('%s/code',BASEDIR);
SCRIPTS = sprintf('%s/scripts',CODEDIR);
addpath(SPMDIR);
addpath(genpath(CODEDIR));

% analysis directories
OUTDIR = sprintf('%s/unpublished-results',BASEDIR);
FLADIR = sprintf('%s/first-level-analysis/sub-%s/%s',OUTDIR,sub,RUN_TYPE);
MASKDIR = sprintf('%s/layer-masks/sub-%s/%s',OUTDIR,sub,RUN_TYPE);

if first_run
    mkdir(FLADIR); mkdir(MASKDIR);
end

%% 0.3) IDENTIFY TARGET IMAGES

% retrieves subject images
[bold_runs, vaso_runs, anat_img] = get_images(sub,SUBBIDS);

% pick desired run type (run bold and vaso separately)
all_runs = eval(sprintf('%s_runs',RUN_TYPE));
N_RUNS = length(all_runs);

%% 0.4) LOAD TIMING VECTORS

% Part 1: generates the timing vectors using python script
if first_run
    cd(CODEDIR)
    cmd = sprintf('python bade-fmri_timing-vectors.py %s', sub);
    system(cmd)
end

% Part 2: reads timing vector file
timing_file = sprintf("%s/bade-info/%s_bade-fmri_timing_vectors.mat",SPM,sub);
timings = load(timing_file);

% Part 3: creates index labels
% use timings.{SUB}_run{X}_{condition} to index the timing vectors

idx_labels = strings(N_RUNS,length(CONDITIONS));
for r = 1:N_RUNS
    for c = 1:length(CONDITIONS)
        idx_labels(r,c) = sprintf("%s_run%d_%s",sub,r,CONDITIONS(c));
    end
end

%% 1) FIRST-LEVEL ANALYSIS

% locates target runs + motion correction txt files
runs = strings(1,N_RUNS); moco_files = strings(1,N_RUNS);
for r = 1:N_RUNS
    runs(r) = sprintf('%s/%s_%s',FUNCDIR,tag,all_runs(r));
    [~,filename,~] = fileparts(all_runs(r));
    moco_files(r) = sprintf('%s/rp_%s.txt',FUNCDIR,filename);
end

matlabbatch = first_level_analysis(runs,moco_files,timings,idx_labels,TR,DURATIONS,CONDITIONS,FLADIR);

cd(FLADIR)
save 1_first-level matlabbatch
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

disp("FIRST-LEVEL ANALYSIS COMPLETE")

%% 2) MODEL ESTIMATION

matlabbatch{1}.spm.stats.fmri_est.spmmat = {sprintf('%s/SPM.mat',FLADIR)};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

cd(FLADIR)
save 2_model_estimation matlabbatch
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

disp("MODEL ESTIMATION COMPLETE")

%% 3.0) CONTRAST SETUP

% CmB = confirm - baseline ; DmB = disconfirm - baseline ; BmC = disconfirm - confirm
CmB = [1 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 -1 0 0 0 0 0 0 0 0 0 0];
DmB = [0 0 1 0 -1 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0];
DmC = [-1 0 1 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 0 0 0 0];

% if vaso --> invert contrast
if strcmp(RUN_TYPE,'vaso')
    CmB = CmB * -1;
    DmB = DmB * -1;
    DmC = DmC * -1;
end

CONTRASTS = {CmB, DmB, DmC}; % array of contrasts
LABELS = {'Confirm - Baseline', 'Disconfirm - Baseline', 'Disconfirm - Confirm'};

%% 3.1) CONTRAST ANALYSIS

matlabbatch = contrast_analysis(CONTRASTS,LABELS,FLADIR);

cd(FLADIR)
save 3_contrast_analysis matlabbatch
spm_jobman('run',matlabbatch)
clear matlabbatch

disp("CONTRAST ANALYSIS COMPLETE")

%% 3.2) UPSAMPLING IMAGES

% need to upsample anat t1-like
% also the contrast T maps

images = strings(1,length(CONTRASTS)+1);
outnames = strings(1,length(CONTRASTS)+1);
upfactors = [4,1,4]; %x,y,z dimensions

% retrieves T maps
for i = 1:length(CONTRASTS)
    images(i) = sprintf('%s/spmT_000%d.nii',FLADIR,i);
    outnames(i) = sprintf('%s/Up_spmT_000%d.nii',MASKDIR,i);
end
% t1-like image
images(end) = sprintf('%s/sub-%s_t1-like-%s.nii',ANATDIR,sub,RUN_TYPE);
outnames(end) = sprintf('%s/Up_sub-%s_t1-like-%s.nii',MASKDIR,sub,RUN_TYPE);

cmd = upsample_images(images,outnames,upfactors,MASKDIR);

% saves command to text file
filename = sprintf('%s/1_upsampling-%s.sh',MASKDIR,RUN_TYPE);
fid = fopen(filename,'w');
fprintf(fid,'%s',cmd);
fclose(fid);

% running the process
cd(MASKDIR)
system(sprintf('source %s',filename))

disp("UPSAMPLING COMPLETE")

%% 4.1) IDENTIFYING ROIS

% manually done on the scans
% draw the ROI masks on the anatomical / mean func scan
% save them in layer-masks folder

% format: layer-masks/sub-XXXX/ROI-mask.nii

ROIS = ["ACC","VC"];
N_LAYERS = 10;

%% 4.2) GROWING LAYERS

% retrieving masks
masks = strings(1,length(ROIS));
for i = 1:length(ROIS)
    masks(i) = sprintf('%s/%s-mask.nii',MASKDIR,ROIS(i));
end

cmd = grow_layers(masks,N_LAYERS,MASKDIR);

% saves command to text file
filename = sprintf('%s/2_grow-layers.sh',MASKDIR);
fid = fopen(filename,'w');
fprintf(fid,'%s',cmd);
fclose(fid);

% running the process
cd(MASKDIR)
system(sprintf('source %s',filename))

disp("LAYER GROWTH COMPLETE")

%% 4.3) LAYER PROFILING

% retrieves T maps
tmaps = strings(1,length(CONTRASTS));
for i = 1:length(CONTRASTS)
    tmaps(i) = sprintf('%s/Up_spmT_000%d.nii',MASKDIR,i);
end

cmd = profile_layers(ROIS,tmaps,MASKDIR);

% saves command to text file
filename = sprintf('%s/3_profile-layers.sh',MASKDIR);
fid = fopen(filename,'w');
fprintf(fid,'%s',cmd);
fclose(fid);

% running the process
cd(MASKDIR)
system(sprintf('source %s',filename))

disp("LAYER PROFILING COMPLETE")

%% 5) DYNAMIC CAUSAL MODELING

