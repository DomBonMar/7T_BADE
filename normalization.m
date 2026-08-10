function matlabbatch = normalization(runs,ANATDIR,FUNCDIR,run_masks,MASKDIR,SPMDIR)

% generates coregistration batch using SPM

% runs >> array containing filenames of all functional runs
% ANATDIR >> folder with anatomical scans
% FUNCDIR >> folder with functional scans
% run_masks >> if TRUE, coregisters masks
% MASKDIR >> folder holding all mask images

addpath(SPMDIR);

% checks if masks need to be collected
if run_masks
    MASKS = get_masks(MASKDIR,'layers');
end


for i = 1:length(runs)

    % if vaso, needs to select corrected run
    if i > length(bold_runs)
        tag = "c";
    else
        tag = "";
    end

    % locates the files to normalize
    if run_masks
        filelist = cell(length(MASKS)+1,1); % all masks + fmri run
    else
        filelist = cell(1);
    end
    
    filelist{1} = sprintf('%s/%sr_%s',FUNCDIR,tag,runs(i));
    [~,run,~] = fileparts(runs(i));

    if run_masks
        for m = 1:length(MASKS)
            mask = sprintf('%s-%s',run,MASKS(m));
            filelist{m+1} = sprintf('%s/%s',MASKDIR,mask);
        end
    end

    % deformation field (y_ file)
    matlabbatch{i}.spm.spatial.normalise.write.subj.def = {sprintf('%s/y_anat-%s',ANATDIR,runs(i))};
    % realigned func file + layered ROI masks
    matlabbatch{i}.spm.spatial.normalise.write.subj.resample = filelist;
    % other params
    matlabbatch{i}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70                                                        
        78 76 85];
    matlabbatch{i}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{i}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{i}.spm.spatial.normalise.write.woptions.prefix = 'w';
end