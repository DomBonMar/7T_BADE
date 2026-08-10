% 7T fMRI - Preprocessing Script
% By domenico

%% 0.1) SCAN INFO AND METADATA

sub = 'U104';
first_run = false; % if first time running script

N_RUNS = 3;
RUN_TYPES = ["bold", "vaso"];
TAGS = ["","b"];

%% 0.2) FILE DIRECTORY SETUP

% baseline directories
BASEDIR = '/data/lavlab/layer-7t-predictive-coding';
DATADIR = sprintf('%s/data',BASEDIR);

% software + code
CODEDIR = sprintf('%s/code',BASEDIR);
addpath(CODEDIR);
SPMDIR = '/home/cic/mardom/Documents/APPS/spm/';
addpath(SPMDIR);
LAYNII = '~/Documents/APPS/LayNii/';

% raw data directories for sub
DICOM = sprintf('%s/mri/dicom/%s',DATADIR,sub);
BIDS = sprintf('%s/mri/bids',DATADIR);
SUBBIDS = sprintf('%s/sub-%s',BIDS,sub);

% processed data directories for sub
SPM = sprintf('%s/mri/spm/%s',DATADIR,sub);
FUNCDIR = sprintf('%s/func',SPM);
ANATDIR = sprintf('%s/anat',SPM);
SCRIPTS = sprintf('%s/scripts',CODEDIR);

% creates all required directories
if first_run
    mkdir(SPM); % dicom given / bids created later
    mkdir(FUNCDIR); mkdir(ANATDIR);
    mkdir(sprintf('%s/bade-info',SPM));
end

%% 1.1) CONVERTING DICOM TO NIFTI

cmd = convert_dicom(sub,DICOM,CODEDIR,BIDS); % retrieves dcm2bids command

% saves command to text file
filename = sprintf('%s/%s_1-convert-dicom.sh',SCRIPTS,sub);
fid = fopen(filename,'w');
fprintf(fid,'%s',cmd);
fclose(fid);

% running the process
cd(BIDS)
system(sprintf('source %s',filename))

disp("DICOM CONVERSION COMPLETE")

%% 1.2) IDENTIFYING TARGET SCANS

% the script is looking for one T1w anat
% also needs VASO + BOLD functional scans

[bold_runs, vaso_runs, anat_img] = get_images(sub,SUBBIDS);

all_runs = {bold_runs,vaso_runs};

%% 1.3) DEFACING SCANS [TO WRITE]

% only need to do the mp2rage scans
cmd = deface_scans(sub,SUBBIDS);

% saves command to text file
filename = sprintf('%s/%s_1-deface.sh',SCRIPTS,sub);
fid = fopen(filename,'w');
fprintf(fid,'%s',cmd);
fclose(fid);

% running the process
cd(BIDS)
system(sprintf('source %s',filename))
disp("DEFACING COMPLETE")

%% 1.4) MOVING DEFACED SCANS

% check that defacing worked first, then run this step

% preserve originals too

system(sprintf('mv %s/anat/sub-%s_acq-mp2rage_INV1.nii %s/anat/sub-%s_acq-mp2rage_INV1_no-deface.nii',SUBBIDS,sub,SUBBIDS,sub))
system(sprintf('mv %s/anat/sub-%s_acq-mp2rage_INV2.nii %s/anat/sub-%s_acq-mp2rage_INV2_no-deface.nii',SUBBIDS,sub,SUBBIDS,sub))
system(sprintf('mv %s/anat/sub-%s_acq-mp2rage_UNIT1.nii %s/anat/sub-%s_acq-mp2rage_UNIT1_no-deface.nii',SUBBIDS,sub,SUBBIDS,sub))
system(sprintf('mv %s/anat/sub-%s_acq-mp2rage_T1map.nii %s/anat/sub-%s_acq-mp2rage_T1map_no-deface.nii',SUBBIDS,sub,SUBBIDS,sub))

system(sprintf('mv %s/anat/sub-%s_acq-mp2rage_INV1_defaced.nii %s/anat/sub-%s_acq-mp2rage_INV1.nii',SUBBIDS,sub,SUBBIDS,sub))
system(sprintf('mv %s/anat/sub-%s_acq-mp2rage_INV2_defaced.nii %s/anat/sub-%s_acq-mp2rage_INV2.nii',SUBBIDS,sub,SUBBIDS,sub))
system(sprintf('mv %s/anat/sub-%s_acq-mp2rage_UNIT1_defaced.nii %s/anat/sub-%s_acq-mp2rage_UNIT1.nii',SUBBIDS,sub,SUBBIDS,sub))
system(sprintf('mv %s/anat/sub-%s_acq-mp2rage_T1map_defaced.nii %s/anat/sub-%s_acq-mp2rage_T1map.nii',SUBBIDS,sub,SUBBIDS,sub))

%% 2) MOTION CORRECTION

% corrects bold / vaso runs separately
for t = 1:length(RUN_TYPES)

    typ = RUN_TYPES(t);
    
    % locating functional scans
    runs = all_runs{t};
    for r = 1:length(runs)
        runs(r) = sprintf('%s/func/%s',SUBBIDS,runs(r));
    end

    matlabbatch = motion_correction(runs,SPMDIR);

    cd(SCRIPTS) % saves job to dir
    save(sprintf('%s_2-motion-correction-%s',sub,typ),'matlabbatch');

    cd(FUNCDIR) % saves output to func dir
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch

    % moving files to SPM dir
    system(sprintf('mv %s/func/mean* %s/func/',SUBBIDS,SPM))
    system(sprintf('mv %s/func/r* %s/func/',SUBBIDS,SPM))
    system(sprintf('mv %s/func/*.mat %s/func/',SUBBIDS,SPM))
    
    fprintf("MOTION CORRECTION COMPLETED for %s", typ)

end

%% 3) CORRECT T2* DEPENDENCY

% this step decontaminates the vaso runs using bold signal
% basically complicated, look at the blog posts

cmd = bold_correction(bold_runs,vaso_runs,FUNCDIR);

% saves commands to text file
filename = sprintf('%s/%s_3-bold-correction.sh',SCRIPTS,sub);
fid = fopen(filename,'w');
fprintf(fid,'%s',cmd);
fclose(fid);

cd(FUNCDIR)
system(sprintf('source %s',filename))

disp("BOLD CORRECTION COMPLETE")

%% 4.1) PICKING BASELINE RUN

% GOAL: coregister all runs to the one with least motion

for t = 1:length(RUN_TYPES)

    typ = RUN_TYPES(t);

    for r = 1:N_RUNS

        [~,filename,~] = fileparts(all_runs{t}(r));
        filename = sprintf('%s/rp_%s.txt',FUNCDIR,filename);
        moco_info = load(filename);
        
        subplot(length(RUN_TYPES),N_RUNS,r+N_RUNS*(t-1))
        plot(moco_info)
        title(sprintf('Motion for %s run %d',typ,r))

    end
end

% min_inds = [1,1]
% sprintf('%s,%d,%d',sub,min_inds(1),min_inds(2))

%% 4.2) GENERATING T1-LIKE IMAGE

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
fid = fopen(filename,'w');
fprintf(fid,'%s',cmd);
fclose(fid);

cd(ANATDIR)
system(sprintf('source %s',filename))

disp("T1-LIKE IMAGE GENERATED")

%% 4.3) COREGISTRATION

% coregister vaso and bold runs separately
% also coregister the t1-like image to each

for t = 1:length(RUN_TYPES)

    typ = RUN_TYPES(t);
    min_ind = min_inds(t);
    tag = TAGS(t);

    % makes a copy of t1-like for coreg
    t1like = sprintf('%s/sub-%s_t1-like-%s.nii',ANATDIR,sub,typ);
    system(sprintf('cp %s/sub-%s_t1-like.nii %s',ANATDIR,sub,t1like))

    % creates array of functional scans (runs + mean)
    mean_img = strings(1,N_RUNS);
    runs = all_runs{t}; % offset for vaso runs
    for r = 1:length(runs)
        mean_img(r) = sprintf('%s/%smean%s',FUNCDIR,tag,runs(r));
        runs(r) = sprintf('%s/%sr_%s',FUNCDIR,tag,runs(r));
    end

    % prepares batch
    matlabbatch = coregistration(runs,mean_img,{t1like},mean_img(min_ind),SPMDIR);

    cd(SCRIPTS)
    save(sprintf('%s_4-coregistration-%s',sub,typ),'matlabbatch');

    cd(FUNCDIR)
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch

    fprintf("\n%s COREGISTRATION COMPLETE\n",upper(typ));

end

%% 4.4) ALIGNMENT CORRECTION

% run this part to align all scans properly

for t = 1:length(RUN_TYPES)

    typ = RUN_TYPES(t);
    runs = all_runs{t};
    min_ind = min_inds(t);
    tag = TAGS(t);

    fprintf('Aligning %s images\n',typ)

    M = spm_get_space(sprintf('%s/c%sr_%s',FUNCDIR,tag,runs(min_ind))); % target alignment

    % functional alignment
    for r = 1:length(runs)
        % skip target file
        if r == min_ind
            continue
        end
        % shift alignment to match target
        fprintf('Aligning %s run %d\n',typ,r)
        V = spm_vol(sprintf('%s/c%sr_%s',FUNCDIR,tag,runs(r))); 
        for n = 1:numel(V)
            spm_get_space(sprintf('%s/c%sr_%s,%d',FUNCDIR,tag,runs(r),n), M);   
        end
    end

    % anat t1-like alignment
    fprintf('Aligning %s t1-like\n',typ)
    spm_get_space(sprintf('%s/sub-%s_t1-like-%s.nii',ANATDIR,sub,typ), M);
end
