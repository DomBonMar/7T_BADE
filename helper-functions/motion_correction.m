function matlabbatch = motion_correction(runs,SPMDIR,PREFIX)

% generates motion correction batch using SPM

% runs >> array containing filenames of all functional runs

addpath(SPMDIR);

for i = 1:length(runs)

    matlabbatch{i}.spm.spatial.realign.estwrite.data = {cellstr(runs(i))};
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
    
end