function out = PROC_coregistration(runs,runtype,anat_img,FUNCDIR,ANATDIR,INFIX,PREFIX)

% generates coregistration batch using SPM

% runs >> array containing filenames of all functional runs
% ANATDIR >> folder with anatomical scans
% FUNCDIR >> folder with functional scans
% anat_img >> filename of the T1w image

out = 1;
n_runs = 0;

fprintf("Running coregistration on %s runs\n",runtype)

% locating anat file in dir
anatfile = compose("%s/%s",ANATDIR,anat_img);

% preparing batch
for r = 1:length(runs)

    % checks if output already generated
    %if isfile(compose("%s/%s%s",FUNCDIR,PREFIX,runs(r)))
	%    fprintf('Skipping: file %s already computed.\n',runs(r))
	%    continue;
    %end

    % else >> adds to batch
    n_runs = n_runs + 1;
    run = compose("%s/%s%s",FUNCDIR,INFIX,runs(r));
    crun = compose("%s/%s%s",FUNCDIR,PREFIX,runs(r));
    system(compose("cp -v %s %s",run,crun))

    meanfile = compose("%s/mean-%s",FUNCDIR,runs(r));

    % fixed image [anat image]
    matlabbatch{r}.spm.spatial.coreg.estimate.ref = cellstr(anatfile);
    % moved image [mean image]
    matlabbatch{r}.spm.spatial.coreg.estimate.source = cellstr(meanfile);
    % other images [func scan as expanded img]
    matlabbatch{r}.spm.spatial.coreg.estimate.other = cellstr(spm_select('expand', crun));
    
    matlabbatch{r}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'ncc';
    matlabbatch{r}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{r}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{r}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    % matlabbatch{r}.spm.spatial.coreg.estwrite.roptions.prefix = PREFIX;

end

if n_runs ~= 0
    spm_jobman('run',matlabbatch) % execute the batch
    clear matlabbatch % clear matlabbatch
end

fprintf("COREGISTRATION COMPLETED for %s\n", runtype)

out = 1;

end