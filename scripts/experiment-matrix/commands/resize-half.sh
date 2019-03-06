#!/bin/bash -e

segment_file="$1"
experiment_dir="$2"

log_level=error

output_file="$experiment_dir/transcode/$(basename $segment_file)"
echo "Resizing $segment_file to half its width and height"
ffmpeg                    \
    -nostdin              \
    -v  $log_level        \
    -i  "$segment_file"   \
    -vf "scale=iw/2:ih/2" \
    "$output_file"

cp "$experiment_dir/segments.txt" "$experiment_dir/transcoded-segments.txt"
