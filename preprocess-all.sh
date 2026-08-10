#!/bin/bash
#SBATCH --job-name=7T_preprocess
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=05:00:00

# load needed modules
module load matlab

# launch parallel job
matlab -batch "preprocessing_script.m"
