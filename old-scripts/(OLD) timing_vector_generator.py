import pandas as pd
import numpy as np

filename = "pilot02_bade-images_2025-09-30_09h02.36.491.xlsx"
df = pd.read_excel(filename)

# strips condition column of whitespaces
df['condition2'] = df['condition2'].str.strip()

N_RUNS = 3
CONDITIONS = ['confirm', 'disconfirm']
SUB = "pilot02"

OUTFILE = f"{SUB}_timing_vectors.txt"
file = open(OUTFILE,'w')

# finds ready key for all runs
rdyKeys = df[~np.isnan(df['rdyKey.started'])]['rdyKey.started'].to_list()

def get_timing_vector(df,condition,onset):
    
    # extracts trials of desired condition
    tmp = df[df['condition2'] == condition]
    
    # generates timing vector
    timings = np.array(tmp['tImg1.started'])
    
    # converts to relative times to start
    return timings - onset
    
# performs procedure for each run / condition
for run in range(1,N_RUNS+1):

    # extracts all trials in run    
    tmp = df[df['run'] == run]
    
    # iterates through conditions
    for cond in CONDITIONS:
        
        # gets timing vector
        timings = get_timing_vector(tmp,cond,rdyKeys[run-1])
        
        # saves output to file
        
        line = f"{SUB}_run{run}_{cond}={timings};\n"
        file.write(line)

    # file.write("\n") # separate runs with newline

file.close()
