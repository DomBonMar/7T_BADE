function out = REG_alignment(runs,runtype,target_run,t1like,FUNCDIR,INFIX,PREFIX)

out = 1;

% ALIGNMENT CORRECTION

% run this part to align all scans properly

fprintf('Aligning %s images\n',runtype)

M = spm_get_space(target_run); % target alignment

% functional alignment
for r = 1:length(runs)

    % creates copy of run => might need to skip this entirely
    run = compose("%s/%s%s",FUNCDIR,INFIX,runs(r));
    outname = compose("%s/%s%s",FUNCDIR,PREFIX,runs(r));
    system(sprintf('cp -v %s %s',run,outname)) % make raw copy

    % skip target file
    if run == target_run
        continue
    end

    % shift alignment to match target
    fprintf('Aligning %s run %s as %s\n',runtype,run,outname)
    V = spm_vol(outname);
    for n = 1:numel(V)
        spm_get_space(sprintf('%s,%d',outname,n), M);   
    end
end

% anat t1-like alignment
fprintf('Aligning %s t1-like\n',runtype)
spm_get_space(sprintf('%s',t1like), M);

out = 0;

end