function [BOLD, VASO, ANAT] = get_images(sub,SUBBIDS)

% retrieves subject's MRI files given a directory
% BOLD -> bold fMRI runs
% VASO -> vaso fMRI runs
% ANAT -> T1w anatomical UNI image

    % patterns used to match target files
    bold_match = sprintf('sub-%s_task-bade_run-*_bold.nii',sub);
    vaso_match = sprintf('sub-%s_task-bade_run-*_vaso.nii',sub);
    anat_match = sprintf('sub-%s_acq-mp2rage_UNIT1.nii',sub);

    % retrieving files
    funcdir = sprintf('%s/func',SUBBIDS);
    cd(funcdir)
    BOLD = dir(bold_match);
    BOLD = string({BOLD.name});
    VASO = dir(vaso_match);
    VASO = string({VASO.name});

    anatdir = sprintf('%s/anat',SUBBIDS);
    cd(anatdir)
    ANAT = dir(anat_match).name;

end