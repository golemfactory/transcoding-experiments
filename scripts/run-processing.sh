#!/bin/bash -e

source functions/all.sh

num_segments="$1"
video_files="${@:2}"

mkdir output/

function run_experiment {
    local experiment_name="$1"
    local video_file="$2"

    echo "Running experiment '$experiment_name' on $video_file"
    experiments/$experiment_name.sh "$num_segments" "$video_file" output
    echo
}

experiments=(
    segment-split-only
    segment-split-half-scale
    segment-split-vp9-convert
)
for experiment in ${experiments[@]}; do
    for video_file in $video_files; do
        run_experiment $experiment "$video_file"
    done
done
