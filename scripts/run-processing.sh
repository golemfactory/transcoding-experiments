#!/bin/bash -e

source functions/all.sh

num_segments="$1"
input_dir="$2"
output_dir="$3"

video_files="$(find "$input_dir" -mindepth 1 -maxdepth 1)"

experiments=(
    segment-split-only
    ss-split-only
    segment-split-half-scale
    ss-split-half-scale
    segment-split-vp9-convert
    segment-split-concat-protocol-merge-half-scale
)
for experiment in ${experiments[@]}; do
    run_experiment_on_all_videos "$num_segments" "$experiment" "$output_dir" "$video_files"
done
