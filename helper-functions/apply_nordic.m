function apply_nordic(noise_volumes,bold_runs,vaso_runs,INDIR,OUTDIR)

% code inspired by https://github.com/LasseKnudsen1/NORDIC-VASO
% mirrors structure of NORDIC-VASO_wrapper.m
% modified to fit our data

% noise_volumes: number of appended noise-volumes at the end of each timeseries 

PREFIX = "n_";

% ARG structure following VASO wrapper
ARG.magnitude_only = 1;
ARG.temporal_phase=1;
ARG.phase_filter_width=10;
ARG.gfactor_patch_overlap=6;
ARG.save_gfactor_map=1;
ARG.save_add_info=1;
ARG.save_residual_matlab=1;
ARG.factor_error=1;
ARG.noise_volume_last=noise_volumes;
ARG.DIROUT=OUTDIR;

% running NORDIC (prefix i)

for r = 1:length(bold_runs)

    fprintf("Applying nordic to bold run %d\n",r)

    % bold runs
    NIFTI_NORDIC(sprintf('%s/%s',INDIR,bold_runs(r)), "", ...
                 sprintf('%s%s',PREFIX,bold_runs(r)), ARG);
    
    fprintf("Applying nordic to vaso run %d\n",r)

    % vaso runs
    NIFTI_NORDIC(sprintf('%s/%s',INDIR,vaso_runs(r)), "", ...
                 sprintf('%s%s',PREFIX,vaso_runs(r)), ARG);

end

end