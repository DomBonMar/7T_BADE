# trial.started-(runs.rdyKey.rt+ready.started)
# trial.started-(runs.rdyKey.rt+ready.started) / TR

import pandas as pd
import numpy as np
from scipy import io

# filename = "pilot02_bade-images_2025-09-30_09h02.36.491.xlsx" --- for pilot02
# filename = "pilot01_bade-images_2025-08-27_09h35.41.956.xlsx"
filename = "pilot3_bade-images_2026-03-12_13h50.07.083.xlsx"

df = pd.read_excel(filename)

# strips condition column of whitespaces
df['condition2'] = df['condition2'].str.strip()

# Pilot01 metadata
# N_RUNS = 4
# CONDITIONS = ['confirm', 'disconfirm', 'baseline']
# SUB = "pilot01"
# N_PER_BLOCK = 20
# RUN_LABEL = "block"
# RDY_RT_LABEL = "rdyKey.rt"
# DIFF_ONSETS = False

# Pilot02/03 metadata
N_RUNS = 3
CONDITIONS = ['confirm', 'disconfirm', 'baseline']
SUB = "pilot03"
N_PER_BLOCK = 4
RUN_LABEL = "run"
RDY_RT_LABEL = 'runs.rdyKey.rt'
DIFF_ONSETS = True


OUTFILE = f"{SUB}_timing_vectors.mat"

OUTDICT = {}

# finds ready key for all runs
rdyKeys = np.array(df[~np.isnan(df['ready.started'])]['ready.started'])
rdyRTs = np.array(df[~np.isnan(df[RDY_RT_LABEL])][RDY_RT_LABEL])
onsets = rdyKeys + rdyRTs

def get_timing_vector(df,condition,onset):
    
    # extracts trials of desired condition
    tmp = df[df['condition2'] == condition]
    
    # generates timing vector
    timings = np.array(tmp['trial.started'])
    
    # converts to relative times to start
    return timings - onset
    
# performs procedure for each run / condition
for run in range(1,N_RUNS+1):

    # extracts all trials in run    
    tmp = df[df[RUN_LABEL] == run]

    # checks if only one recording (ie, one onset for all runs)
    if DIFF_ONSETS:
        run_onset = onsets[run-1]
    else:
        run_onset = onsets[0]
    
    # iterates through conditions
    for cond in CONDITIONS:

        # gets timing vector
        timings = get_timing_vector(tmp,cond,run_onset)
        
        # saves output to file
        
        line = f"{SUB}_run{run}_{cond}"
        OUTDICT[line] = timings

    # saves baseline fixation between trials
    # fixation only occurs at end of each block
    timings = np.array(tmp['fix.started']) - run_onset
    timings = timings[N_PER_BLOCK-1::N_PER_BLOCK]
    line = f"{SUB}_run{run}_baseline"
    OUTDICT[line] = timings

    # file.write("\n") # separate runs with newline

# saves directly in matlab format
io.savemat(OUTFILE,OUTDICT)
