function out = PROC_motion_correction(runs,runtype,INDIR,OUTDIR,INFIX,PREFIX)

% generates motion correction batch using SPM

% runs >> array containing filenames of all functional runs

out = 1;

cd(OUTDIR)

fprintf("Running on %s run\n",runtype)

% preparing batch
for i = 1:length(runs)

    run = sprintf('%s/%s%s',INDIR,INFIX,runs(i));

    matlabbatch{i}.spm.spatial.realign.estwrite.data = {cellstr(run)};
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.quality = 0.95;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.sep = 1.5;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.fwhm = 1;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.prefix = PREFIX;

end

% running process

%save(sprintf('%s_2-motion-correction-%s',sub,typ),'matlabbatch');

spm_jobman('run',matlabbatch) % execute the batch
clear matlabbatch % clear matlabbatch

fprintf("MOTION CORRECTION COMPLETED for %s", runtype)
    
out = 0;

end