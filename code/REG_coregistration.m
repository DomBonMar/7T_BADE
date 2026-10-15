function out = REG_coregistration(runs,runtype,target_img,t1like,FUNCDIR,INFIX,PREFIX)

% coregister vaso and bold runs separately
% also coregister the t1-like image to each

out = 1;
c = 0;

% COREGISTRATION
fprintf("Coregistration for %s runs.\n",runtype)

% prepares batch for func images
N_RUNS = length(runs);
for r = 1:N_RUNS

    mean_img = compose("%s/mean-%s",FUNCDIR,runs(r));
    run = compose("%s/%s%s",FUNCDIR,INFIX,runs(r));
    c = c + 1;

    % fixed image [least motion mean image]
    matlabbatch{c}.spm.spatial.coreg.estwrite.ref = cellstr(target_img);
    % moved image [other mean image]
    matlabbatch{c}.spm.spatial.coreg.estwrite.source = cellstr(mean_img);
    % other images [other func run]
    matlabbatch{c}.spm.spatial.coreg.estwrite.other = cellstr(spm_select('expand', run));
    
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'ncc';
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 0 0];
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.prefix = PREFIX;

end

% adds t1-like image to batch

c = c + 1;

% fixed image
matlabbatch{c}.spm.spatial.coreg.estwrite.ref = cellstr(target_img);
% moved image [t1-like]
matlabbatch{c}.spm.spatial.coreg.estwrite.source = cellstr(t1like);

matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'ncc';
matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{c}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 0 0];
matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
matlabbatch{c}.spm.spatial.coreg.estwrite.roptions.interp = 4;

cd(FUNCDIR)
spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch

fprintf("\n%s COREGISTRATION COMPLETE\n",upper(runtype));

out = 0;

end