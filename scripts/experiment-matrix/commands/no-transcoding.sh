#!/bin/bash -e

segment_file="$1"
experiment_dir="$2"

output_file="$experiment_dir/transcode/$(basename $segment_file)"
echo "No transcoding, just linking $output_file -> $segment_file"
ln "$segment_file" "$output_file"

cp "$experiment_dir/segments.txt" "$experiment_dir/transcoded-segments.txt"
