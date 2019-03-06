#!/bin/bash -e

segment_file="$1"
experiment_dir="$2"

log_level=error

segment_basename="$(basename $segment_file)"
segment_prefix="${segment_basename%%.*}"
output_file="$experiment_dir/transcode/$segment_prefix.mkv"

echo "Converting $segment_file to VP9 in a MKV container"
ffmpeg                      \
    -nostdin                \
    -v      $log_level      \
    -i      "$segment_file" \
    -vcodec vp9             \
    "$output_file"

echo -n "" > "$experiment_dir/transcoded-segments.txt"
cat "$experiment_dir/segments.txt" | while read -r line; do
    echo "${line%.*}.mkv" >> "$experiment_dir/transcoded-segments.txt"
done
