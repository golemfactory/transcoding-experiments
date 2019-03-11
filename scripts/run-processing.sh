#!/bin/bash -e

source functions/all.sh

num_segments="$1"
input_dir="$2"
output_dir="$3"

video_files="$(find "$input_dir" -mindepth 1 -maxdepth 1)"

mkdir --parents "$output_dir"

function run_experiment {
    local experiment_name="$1"
    local video_file="$2"

    echo "Running experiment '$experiment_name' on $video_file"
    experiments/$experiment_name.sh "$num_segments" "$video_file" "$output_dir"
    echo
}

experiments=(
    segment-split-only
    ss-split-only
    segment-split-half-scale
    ss-split-half-scale
    segment-split-vp9-convert
    segment-split-concat-protocol-merge-half-scale
)
for experiment in ${experiments[@]}; do
    for video_file in $video_files; do
        run_experiment $experiment "$video_file"
    done
done
