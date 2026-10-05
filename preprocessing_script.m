% 7T fMRI - Preprocessing Script
% By domenico

%% 0.1) SCAN INFO AND METADATA

sub = 'U106';
first_run = true; % if first time running script

N_RUNS = 3;
RUN_TYPES = ["bold", "vaso"];
NOISE_VOL = 0;

% expected mp2rage outputs
anat_files = {'acq-mp2rage_INV1',...
    'acq-mp2rage_INV2',...
    'acq-mp2rage_UNIT1',...
    'acq-mp2rage_T1map'};
preserve_originals = true; % defacing step

% PREFIXES USED AT EACH STEP
step_nord = ''; % empty for now
step_moco = 'r_';
step_boco = 'b';
step_corg = 'c';

PREFIX_NORD = step_nord;
PREFIX_MOCO = [step_moco,PREFIX_NORD];
PREFIX_BOCO = {PREFIX_MOCO,...
    [step_boco,PREFIX_MOCO]}; % 1 -> bold, 2 -> vaso
PREFIX_CORG = {[step_corg,PREFIX_BOCO{1}],...
    [step_corg,PREFIX_BOCO{2}]};

%% 0.2) FILE DIRECTORY SETUP

% baseline directories [ONLY EDIT THESE]
BASEDIR = '/data/lavlab/layer-7t-predictive-coding';
APPS = '~/Documents/APPS';

% software + code
CODEDIR = sprintf('%s/code',BASEDIR);
SPM = sprintf('%s/spm',APPS);
LAYNII = sprintf('%s/LayNii',APPS);
NORDIC = sprintf('%s/NORDIC',APPS);

addpath(genpath(CODEDIR)); addpath(SPM); addpath(NORDIC);

% raw data directories for sub
DATADIR = sprintf('%s/data',BASEDIR);
DICOM = sprintf('%s/mri/dicom/%s',DATADIR,sub);
BIDS = sprintf('%s/mri/bids',DATADIR);
SUBBIDS = sprintf('%s/sub-%s',BIDS,sub);

% processed data directories for sub
SPMDIR = sprintf('%s/mri/spm/%s',DATADIR,sub);
FUNCDIR = sprintf('%s/func',SPMDIR);
ANATDIR = sprintf('%s/anat',SPMDIR);
SCRIPTS = sprintf('%s/script-logs',BASEDIR);

% creates all required directories
if first_run
    mkdir(SPMDIR); % dicom given / bids created later
    mkdir(FUNCDIR); mkdir(ANATDIR);
    mkdir(sprintf('%s/bade-info',SPMDIR));
end

%% 1.1) CONVERTING DICOM TO NIFTI

cmd = convert_dicom(sub,DICOM,CODEDIR,BIDS); % retrieves dcm2bids command

% saves command to text file
filename = sprintf('%s/%s_1-convert-dicom.sh',SCRIPTS,sub);
save_and_run(filename,cmd,BIDS)

disp("DICOM CONVERSION COMPLETE")

%% 1.2) IDENTIFYING TARGET SCANS

% the script is looking for one T1w anat
% also needs VASO + BOLD functional scans

[bold_runs, vaso_runs, anat_img] = get_images(sub,SUBBIDS);

all_runs = {bold_runs,vaso_runs};

% also, manually QC the functional images here

%% 2.1) DEFACING SCANS

% only need to do the mp2rage scans
cmd = deface_scans(anat_files,SUBBIDS);

% saves command to text file
filename = sprintf('%s/%s_1-deface.sh',SCRIPTS,sub);
save_and_run(filename,cmd,BIDS)

disp("DEFACING COMPLETE")

%% 2.2) MOVING DEFACED SCANS

% check that defacing worked first, then run this step

for i = 1:length(anat_files)

    % if preseve >> saves copy of original
    if preserve_originals
        system(sprintf('mv %s/anat/sub-%s_%s.nii %s/anat/sub-%s_%s_no-deface.nii',...
            SUBBIDS,sub,anat_files{i},SUBBIDS,sub,anat_files{i}))
    end

    % renames defaced file to preserve name
    system(sprintf('mv %s/anat/sub-%s_%s_defaced.nii %s/anat/sub-%s_%s.nii',...
        SUBBIDS,sub,anat_files{i},SUBBIDS,sub,anat_files{i}));

end

%% 3) APPLYING NORDIC DENOISING

% applies denoising to the functional runs
apply_nordic(NOISE_VOL,bold_runs,vaso_runs,sprintf('%s/func',SUBBIDS),FUNCDIR,step_nord)

disp("NORDIC COMPLETE")

%% 4) MOTION CORRECTION

% corrects bold / vaso runs separately
for t = 1:length(RUN_TYPES)

    typ = RUN_TYPES(t);
    
    % locating functional scans
    runs = all_runs{t};
    for r = 1:length(runs)
        %runs(r) = sprintf('%s/%s%s',FUNCDIR,PREFIX_NORD,runs(r));
        %REVERT ONCE NORDIC FIXED
        runs(r) = sprintf('%s/func/%s',SUBBIDS,runs(r));
    end

    matlabbatch = motion_correction(runs,SPM,step_moco); %SAME THING
    %matlabbatch = motion_correction(runs,SPM,PREFIX_MOCO);

    cd(SCRIPTS) % saves job to dir
    save(sprintf('%s_2-motion-correction-%s',sub,typ),'matlabbatch');

    cd(FUNCDIR) % saves output to func dir
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch
    
    fprintf("MOTION CORRECTION COMPLETED for %s", typ)

end

% moving files to SPM dir
system(sprintf('mv %s/func/mean* %s/func/',SUBBIDS,SPMDIR));
system(sprintf('mv %s/func/rp_* %s/func/',SUBBIDS,SPMDIR));
system(sprintf('mv %s/func/%s* %s/func/',SUBBIDS,PREFIX_MOCO,SPMDIR));
system(sprintf('mv %s/func/*.mat %s/func/',SUBBIDS,SPMDIR));

%% 5) CORRECT T2* DEPENDENCY

% this step decontaminates the vaso runs using bold signal
% basically complicated, look at the blog posts

% Step 1: boco for functional runs
disp("Running BOCO for functional runs")
pbold = strings(1,N_RUNS); pvaso = strings(1,N_RUNS);

for r = 1:N_RUNS
    pbold(r) = sprintf('%s%s',PREFIX_MOCO,bold_runs(r));
    pvaso(r) = sprintf('%s%s',PREFIX_MOCO,vaso_runs(r));
end

cmd = bold_correction(pbold,pvaso,FUNCDIR,step_boco);

% saves commands to text file
filename = sprintf('%s/%s_3-bold-correction-func.sh',SCRIPTS,sub);
save_and_run(filename,cmd,FUNCDIR)

% Step 2: repeating for mean files
disp("Running BOCO for mean images")
mbold = strings(1,N_RUNS); mvaso = strings(1,N_RUNS);

for r = 1:N_RUNS
    mbold(r) = sprintf('mean%s',bold_runs(r)); % DO WE NEED NORD PREFIX?
    mvaso(r) = sprintf('mean%s',vaso_runs(r));
end

cmd = bold_correction(mbold,mvaso,FUNCDIR,step_boco);

% saves commands to text file
filename = sprintf('%s/%s_3-bold-correction-mean.sh',SCRIPTS,sub);
save_and_run(filename,cmd,FUNCDIR)

disp("BOLD CORRECTION COMPLETE")

%% 6.1) PICKING BASELINE RUN

% GOAL: coregister all runs to the one with least motion

for t = 1:length(RUN_TYPES)

    typ = RUN_TYPES(t);

    for r = 1:N_RUNS

        [~,filename,~] = fileparts(all_runs{t}(r));
        filename = sprintf('%s/rp_%s.txt',FUNCDIR,filename); % PREFIX NORD
        moco_info = load(filename);
        
        subplot(length(RUN_TYPES),N_RUNS,r+N_RUNS*(t-1))
        plot(moco_info)
        title(sprintf('Motion for %s run %d',typ,r))

    end
end

% min_inds = [2,2]
% sprintf('%s,%d,%d',sub,min_inds(1),min_inds(2))

%% 6.2) GENERATING T1-LIKE IMAGE

% using the lowest motion runs as a template
target_img = strings(1,2);
for t = 1:length(RUN_TYPES)
    target_img(t) = sprintf('%s/mean%s',FUNCDIR,all_runs{t}(min_inds(t)));
end

% output name for t1-like img
t1_name = sprintf('sub-%s_t1-like.nii',sub);

cmd = generate_t1_like(target_img(1),target_img(2),t1_name,ANATDIR);

% saves commands to text file
filename = sprintf('%s/%s_4-gen-t1-like.sh',SCRIPTS,sub);
save_and_run(filename,cmd,ANATDIR)

disp("T1-LIKE IMAGE GENERATED")

%% 7.1) COREGISTRATION

% coregister vaso and bold runs separately
% also coregister the t1-like image to each

for t = 1:length(RUN_TYPES)

    typ = RUN_TYPES(t);
    min_ind = min_inds(t);
    prefix = PREFIX_BOCO{t};
    if strcmp(typ,'bold')
        tag = '';
    else
        tag = step_boco;
    end

    % makes a copy of t1-like for coreg
    t1like = sprintf('%s/sub-%s_t1-like-%s.nii',ANATDIR,sub,typ);
    system(sprintf('cp %s/sub-%s_t1-like.nii %s',ANATDIR,sub,t1like))

    % creates array of functional scans (runs + mean)
    mean_img = strings(1,N_RUNS);
    runs = all_runs{t}; % offset for vaso runs
    for r = 1:length(runs)
        mean_img(r) = sprintf('%s/%smean%s',FUNCDIR,tag,runs(r));
        runs(r) = sprintf('%s/%s%s',FUNCDIR,prefix,runs(r));
    end

    % prepares batch
    matlabbatch = coregistration(runs,mean_img,{t1like},mean_img(min_ind),SPM);

    cd(SCRIPTS)
    save(sprintf('%s_4-coregistration-%s',sub,typ),'matlabbatch');

    cd(FUNCDIR)
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch

    fprintf("\n%s COREGISTRATION COMPLETE\n",upper(typ));

end

%% 7.2) ALIGNMENT CORRECTION

% run this part to align all scans properly

for t = 1:length(RUN_TYPES)

    typ = RUN_TYPES(t);
    runs = all_runs{t};
    min_ind = min_inds(t);
    prefix = PREFIX_CORG{t};

    fprintf('Aligning %s images\n',typ)

    M = spm_get_space(sprintf('%s/%s%s',FUNCDIR,prefix,runs(min_ind))); % target alignment

    % functional alignment
    for r = 1:length(runs)
        % skip target file
        if r == min_ind
            continue
        end
        % shift alignment to match target
        fprintf('Aligning %s run %d\n',typ,r)
        V = spm_vol(sprintf('%s/%s%s',FUNCDIR,prefix,runs(r))); 
        for n = 1:numel(V)
            spm_get_space(sprintf('%s/%s%s,%d',FUNCDIR,prefix,runs(r),n), M);   
        end
    end

    % anat t1-like alignment
    fprintf('Aligning %s t1-like\n',typ)
    spm_get_space(sprintf('%s/sub-%s_t1-like-%s.nii',ANATDIR,sub,typ), M);
end
