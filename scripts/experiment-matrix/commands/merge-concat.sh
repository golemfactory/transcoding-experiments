#!/bin/bash -e

experiment_dir="$1"

log_level=error

echo -n "" > "$experiment_dir/merge-input.ffconcat"
cat "$experiment_dir/transcoded-segments.txt" | while read -r line; do
    echo "file '$(realpath "$experiment_dir/transcode/$line")'" >> "$experiment_dir/merge-input.ffconcat"
done

first_segment_basename="$(basename "$(head $experiment_dir/transcoded-segments.txt -n 1)")"
first_segment_extension="${first_segment_basename##*.}"

merged_file="$experiment_dir/transcoded-merged.$first_segment_extension"
echo "Merging segments with ffmpeg -f concat into $merged_file"
ffmpeg                                           \
    -nostdin                                     \
    -v    $log_level                             \
    -f    concat                                 \
    -safe 0                                      \
    -i    "$experiment_dir/merge-input.ffconcat" \
    -c    copy                                   \
    "$merged_file"
