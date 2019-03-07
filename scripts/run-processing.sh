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

for video_file in $video_files; do
    run_experiment segment-split-only        "$video_file"
done
for video_file in $video_files; do
    run_experiment segment-split-half-scale  "$video_file"
done
for video_file in $video_files; do
    run_experiment segment-split-vp9-convert "$video_file"
done
