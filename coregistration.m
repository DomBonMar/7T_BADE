function matlabbatch = coregistration(func_img,mean_img,anat_img,fixed_img,SPMDIR)

% generates coregistration batch using SPM

% target_ind >> index of the least motion run in array
% runs >> array containing filenames of all functional runs
% ANATDIR >> folder with anatomical scans
% FUNCDIR >> folder with functional scans
% anat_img >> filename of the T1w image

addpath(SPMDIR);

c = 0; % batch counter

% coregisters functional runs
for i = 1:length(func_img)

    c = c + 1;

    % fixed image [least motion mean image]
    matlabbatch{c}.spm.spatial.coreg.estwrite.ref = cellstr(fixed_img);
    % moved image [other mean image]
    matlabbatch{c}.spm.spatial.coreg.estwrite.source = cellstr(mean_img(i));
    % other images [other func run]
    matlabbatch{c}.spm.spatial.coreg.estwrite.other = cellstr(spm_select('expand', func_img(i)));
    
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'ncc';
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 0 0];
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.prefix = 'c';

end

% coregisters anatomical images
for i = 1:length(anat_img)

    c = c + 1;

    % fixed image
    matlabbatch{c}.spm.spatial.coreg.estwrite.ref = cellstr(fixed_img);
    % moved image [t1-like]
    matlabbatch{c}.spm.spatial.coreg.estwrite.source = cellstr(anat_img(i));
    
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'ncc';
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 0 0];
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.interp = 4;
end

end