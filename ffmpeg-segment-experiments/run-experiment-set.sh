#!/bin/bash -e

if [[ "$1" == "--clear-output" ]]; then
    echo "Removing the output/ directory"
    rm -rf output/
    shift
fi

num_segments="$1"
input_dir="$2"
output_dir="$3"
experiment_set="$4"

experiment_set_path="experiment-sets/$experiment_set.sh"

if [[ "$num_segments" == "" ]]; then
    num_segments=5
fi

if [[ "$input_dir" == "" ]]; then
    input_dir=input
fi

if [[ "$output_dir" == "" ]]; then
    output_dir=output
fi

if [[ ! -e "$experiment_set_path" ]]; then
    echo "Experiment set '$experiment_set' does not exist in experiment-sets/"
    exit 1
fi

./$experiment_set_path "$num_segments" "$input_dir" "$output_dir"
