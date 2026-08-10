# usage via command line
# python bade-fmri_timing-vectors.py {SUB-ID}

# OUTPUT: {SUB}_bade-fmri_timing_vectors.mat

import pandas as pd
import numpy as np
import sys
from scipy import io
from pathlib import Path

# scan metadata
SUB = sys.argv[1]
DATADIR = "/data/lavlab/layer-7t-predictive-coding/data"
BADEDIR = Path(f"{DATADIR}/bade_fmri_task")
SPMDIR = f"{DATADIR}/mri/spm"

# task metadata
N_RUNS = 3
CONDITIONS = ['confirm', 'disconfirm']
N_TRIALS_PER_BLOCK = 4

# helper function
def get_timing_vector(df,condition,onset):
    # extracts trials of desired condition
    tmp = df[df['condition2'] == condition]
    # generates timing vector
    timings = np.array(tmp['trial.started'])
    # converts to relative times to start
    return timings - onset

# loading timing file
pattern = f"{SUB}_bade-images*.csv"
filename = list(BADEDIR.glob(pattern))
print(f"Using following file: {filename[0]}")
df = pd.read_csv(str(filename[0]))
df['condition2'] = df['condition2'].str.strip() # strips condition column of whitespaces

# finds ready key for all runs
rdyKeys = np.array(df[~np.isnan(df['ready.started'])]['ready.started'])
rdyRTs = np.array(df[~np.isnan(df['runs.rdyKey.rt'])]['runs.rdyKey.rt'])
onsets = rdyKeys + rdyRTs
    
OUTDICT = {}

# collects timings for each run / condition
for run in range(1,N_RUNS+1):

    # extracts all trials in run    
    run_trials = df[df["run"] == run]
    run_onset = onsets[run-1]

    # iterates through conditions
    for cond in CONDITIONS:
        # gets timing vector
        timings = get_timing_vector(run_trials,cond,run_onset)
        # saves output to file   
        line = f"{SUB}_run{run}_{cond}"
        OUTDICT[line] = timings

    # saves baseline fixation between trials (at end of each block)
    timings = np.array(run_trials['fix.started']) - run_onset
    timings = timings[N_TRIALS_PER_BLOCK-1::N_TRIALS_PER_BLOCK]
    line = f"{SUB}_run{run}_baseline"
    OUTDICT[line] = timings

# saves directly in matlab format
OUTFILE = f"{SPMDIR}/{SUB}/bade-info/{SUB}_bade-fmri_timing_vectors.mat"
io.savemat(OUTFILE,OUTDICT)
