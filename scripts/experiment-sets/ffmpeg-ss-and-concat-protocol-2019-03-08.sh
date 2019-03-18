#!/bin/bash -e

source functions/all.sh

num_segments="$1"
input_dir="$2"
output_dir="$3"

video_files="$(find "$input_dir" -mindepth 1 -maxdepth 1)"

experiments=(
    ss-split-only
    ss-split-half-scale
    segment-split-concat-protocol-merge-half-scale
)
for experiment in ${experiments[@]}; do
    run_experiment_on_all_videos "$num_segments" "$experiment" "$output_dir" "$video_files"
done

input_file_info_report       "$output_dir" ss-split-half-scale

timestamps_report            "$output_dir" ss-split-half-scale
timestamps_report            "$output_dir" segment-split-concat-protocol-merge-half-scale

frame_type_report            "$output_dir" ss-split-half-scale
frame_type_report            "$output_dir" segment-split-concat-protocol-merge-half-scale

frame_type_report_split_only "$output_dir" ss-split-only

frame_type_dump_report       "$output_dir" ss-split-only
