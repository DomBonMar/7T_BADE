#!/bin/bash

BASEDIR=$(pwd)

script=$1
participant_file="${BASEDIR}/data/bids/participants.tsv"

n_subs=$(( $( wc -l "${participant_file}" | cut -f1 -d' ' ) - 1 ))

echo "Submitting ${script} with array 0-${n_subs} subjects"

sbatch --array=0-"${n_subs}" "$script"
