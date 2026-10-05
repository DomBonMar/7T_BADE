function out = apply_nordic(noise_volumes,bold_runs,vaso_runs,INDIR,OUTDIR,INFIX,PREFIX)

% code inspired by https://github.com/LasseKnudsen1/NORDIC-VASO
% mirrors structure of NORDIC-VASO_wrapper.m
% modified to fit our data

% noise_volumes: number of appended noise-volumes at the end of each timeseries

out = 1; % if unsuccessful

disp(noise_volumes)
disp(bold_runs)
disp(vaso_runs)
disp(INDIR)
disp(OUTDIR)
disp(INFIX)
disp(PREFIX)

% converts bash arguments to matlab format
bold_runs = split(bold_runs, " ");
vaso_runs = split(vaso_runs, " ");

% ARG structure following VASO wrapper
ARG = struct;
ARG.NORDIC = 1;
ARG.magnitude_only = 1;
ARG.save_gfactor_map=0;
ARG.save_add_info=0;
ARG.save_residual_matlab=0;
ARG.factor_error=1;
ARG.noise_volume_last=str2num(noise_volumes);
ARG.DIROUT=OUTDIR;

% running NORDIC (prefix i)

for r = 1:length(bold_runs)

    fprintf("Applying nordic to bold run %d\n",r)

    % bold runs
    NIFTI_NORDIC(sprintf('%s/%s%s',INDIR,INFIX,bold_runs(r)), "", ...
                 sprintf('%s%s',PREFIX,bold_runs(r)), ARG);
    
    fprintf("Applying nordic to vaso run %d\n",r)

    % vaso runs
    NIFTI_NORDIC(sprintf('%s/%s%s',INDIR,INFIX,vaso_runs(r)), "", ...
                 sprintf('%s%s',PREFIX,vaso_runs(r)), ARG);

end

out = 0;

end
