function out = PROC_nordic_denoising(noise_volumes,runs,runtype,INDIR,OUTDIR,INFIX,PREFIX)

% code inspired by https://github.com/LasseKnudsen1/NORDIC-VASO
% mirrors structure of NORDIC-VASO_wrapper.m
% modified to fit our data

% noise_volumes: number of appended noise-volumes at the end of each timeseries

out = 1; % if unsuccessful
cd(OUTDIR)

% converts bash arguments to matlab format
%bold_runs = split(bold_runs, " ");
%vaso_runs = split(vaso_runs, " ");

% ARG structure following VASO wrapper
ARG = struct;
ARG.NORDIC = 1;
ARG.magnitude_only = 1;
ARG.save_gfactor_map=0;
ARG.save_add_info=0;
ARG.save_residual_matlab=0;
ARG.factor_error=1;
ARG.noise_volume_last=str2double(noise_volumes);
ARG.DIROUT=compose("%s/",OUTDIR);

% running NORDIC (prefix i)

for r = 1:length(runs)

    fprintf("Applying nordic to %s run %d\n",runtype,r)

    infile = compose("%s/%s%s",INDIR,INFIX,runs(r));
    outfile = compose("%s%s",PREFIX,runs(r));

    if isfile(compose("%s/%s",OUTDIR,outfile))
	    disp('Skipping: file already computed.')
	    continue;
    else
	    fprintf("Using file %s\n",infile)
	    fprintf("Renaming output to %s\n",outfile)
	    NIFTI_NORDIC(infile, "", outfile, ARG);
    end

end

out = 0;

end
