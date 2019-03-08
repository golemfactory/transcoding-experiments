#!/bin/bash -e

if [[ "$1" == "--clear-output" ]]; then
    echo "Removing the output/ directory"
    rm -rf output/
    shift
fi

num_segments="$1"
input_dir="$2"
output_dir="$3"

if [[ "$num_segments" == "" ]]; then
    num_segments=5
fi

if [[ "$input_dir" == "" ]]; then
    input_dir=input
fi

if [[ "$output_dir" == "" ]]; then
    output_dir=output
fi

./run-processing.sh "$num_segments" "$input_dir" "$output_dir"
./run-reports.sh "$output_dir"
