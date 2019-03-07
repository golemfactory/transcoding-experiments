#!/bin/bash -e

source functions/all.sh

num_segments="$1"
video_file="$2"
output_dir="$3"

output_format="$(get_extension "$video_file")"
experiment_name="$(basename_without_extension "${BASH_SOURCE[0]}")"
experiment_dir="$output_dir/$experiment_name/$(basename "$video_file")"

split_with_ffmpeg_segment \
    "$num_segments"       \
    "$video_file"         \
    "$experiment_dir/split"

mkdir --parents "$experiment_dir/transcode"
cp "$experiment_dir/split/segments.txt" "$experiment_dir/transcode/segments.txt"

for segment_file in $(cat "$experiment_dir/split/segments.txt"); do
    ffmpeg_scale                              \
        0.5                                   \
        "$experiment_dir/split/$segment_file" \
        "$experiment_dir/transcode/$segment_file"
done

merge_with_ffmpeg_concat        \
    "$experiment_dir/transcode" \
    "$experiment_dir"           \
    "$output_format"

ffmpeg_scale      \
    0.5           \
    "$video_file" \
    "$experiment_dir/monolithic.$output_format"
