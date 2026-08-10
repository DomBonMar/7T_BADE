#!/bin/bash
#SBATCH --account=dombon4
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=2000

# script used to preprocessing 7T datasets in parallel
# Written by Domenico

module load matlab

matlab -nojvm -batch "par_preprocess"
