#!/bin/bash -e

reference_file="$1"
new_file="$2"
output_dir="$3"
duration="$4"

log_level=error

echo "Dumping frames for the first $duration seconds of the difference between the videos"
mkdir -p "$output_dir/diff-frames/"
ffmpeg                                          \
    -nostdin                                    \
    -v              $log_level                  \
    -i              "$reference_file"           \
    -i              "$new_file"                 \
    -to             "$duration"                 \
    -filter_complex "blend=all_mode=difference" \
    "$output_dir/diff-frames/frame-%05d.png"

echo "Dumping frames for the first $duration seconds of the reference video"
mkdir -p "$output_dir/reference-frames/"
ffmpeg                    \
    -nostdin              \
    -v  $log_level        \
    -i  "$reference_file" \
    -to "$duration"       \
    "$output_dir/reference-frames/frame-%05d.png"

echo "Dumping frames for the first $duration seconds of the new video"
mkdir -p "$output_dir/new-frames/"
ffmpeg              \
    -nostdin        \
    -v  $log_level  \
    -i  "$new_file" \
    -to "$duration" \
    "$output_dir/new-frames/frame-%05d.png"
