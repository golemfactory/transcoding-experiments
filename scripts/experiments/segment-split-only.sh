#!/bin/bash -e

source functions/all.sh

num_segments="$1"
video_file="$2"
output_dir="$3"

experiment_name="$(basename_without_extension "${BASH_SOURCE[0]}")"

input_extension="$(get_extension "$video_file")"
experiment_dir="$output_dir/$experiment_name/$(basename "$video_file")"

split_with_ffmpeg_segment "$num_segments" "$video_file" "$experiment_dir/split"
merge_with_ffmpeg_concat "$experiment_dir/split" "$experiment_dir" "$input_extension"
