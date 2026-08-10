% 7T fMRI - Parallel Preprocessing Script
% By domenico [summer 2026]

% parallel setup
nthreads = str2num(getenv('SLURM_CPUS_PER_TASK'));
parpool("Threads",nthreads);

% create list of subjects + TRs
SUBJECTS = [];
TRS = [];

% specify run details
first_run = true;
run_masks = false;

parfor i = 1:length(SUBJECTS)
    preprocessing_script(SUBJECTS(i),TRS(i),first_run,run_masks)
end


