function out = PROC_coregistration(runs,runtype,anat_img,FUNCDIR,ANATDIR,INFIX)

% generates coregistration batch using SPM

% runs >> array containing filenames of all functional runs
% ANATDIR >> folder with anatomical scans
% FUNCDIR >> folder with functional scans
% anat_img >> filename of the T1w image

out = 1;
n = 0;

fprintf("Running coregistration on %s runs\n",runtype)

% locating anat file in dir
anatfile = compose("%s/%s",ANATDIR,anat_img);

% preparing batch
for r = 1:length(runs)

    anatout = compose("%s/anat-%s",ANATDIR,runs(r));

    % checks if output already generated
    if isfile(anatout)
	   fprintf('Skipping: file %s already computed.\n',runs(r))
	   continue;
    end

    % else >> adds to batch
    n = n + 1;
    run = compose("%s/%s%s",FUNCDIR,INFIX,runs(r));
    meanfile = compose("%s/mean-%s",FUNCDIR,runs(r));
    system(compose("cp -v %s %s",anatfile,anatout)); % makes a copy of anat file

    % fixed image [mean image]
    matlabbatch{n}.spm.spatial.coreg.estimate.ref = cellstr(meanfile);
    % moved image [anat image]
    matlabbatch{n}.spm.spatial.coreg.estimate.source = cellstr(anatout);
    % other images [func scan as expanded img]
    matlabbatch{n}.spm.spatial.coreg.estimate.other = cellstr(spm_select('expand', run));
    
    matlabbatch{n}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'ncc';
    matlabbatch{n}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{n}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{n}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    % matlabbatch{n}.spm.spatial.coreg.estwrite.roptions.prefix = PREFIX;

end

if n ~= 0
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch
end

fprintf("COREGISTRATION COMPLETED for %s\n", runtype)

out = 0;

end