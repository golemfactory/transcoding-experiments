#!/bin/bash -e

source functions/all.sh

num_segments="$1"
video_file="$2"
output_dir="$3"

experiment_name="$(basename_without_extension "${BASH_SOURCE[0]}")"

input_format="$(get_extension "$video_file")"
input_file="$experiment_dir/input.$input_format"
experiment_dir="$output_dir/$experiment_name/$(basename "$video_file")"

mkdir --parents "$experiment_dir"
cp "$video_file" "$input_file"

split_with_ffmpeg_segment "$num_segments" "$input_file" "$experiment_dir/split"
merge_with_ffmpeg_concat "$experiment_dir/split" "$experiment_dir" "$input_format"
