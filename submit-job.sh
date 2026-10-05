#!/bin/bash

BASEDIR=$(pwd)

local script=$1
local participant_file="${BASEDIR}/data/bids/participants.tsv"

n_subs=$(( $( wc -l "${participant_file}" | cut -f1 -d' ' ) - 2 ))

echo "Submitting ${script} with array 0-${n_subs} subjects"

sbatch --array=0-"${n_subs}" "$script"
