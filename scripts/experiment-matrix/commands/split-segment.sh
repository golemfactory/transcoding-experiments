#!/bin/bash -e

input_file="$1"
experiment_dir="$2"
num_segments="$3"

log_level=error

duration=$(
    ffprobe                                              \
        -v            $log_level                         \
        -show_entries format=duration                    \
        -of           default=noprint_wrappers=1:nokey=1 \
        "$input_file"
)
rounded_duration=$(printf "%.0f" "$duration")
segment_duration=$((rounded_duration  / num_segments))
echo "Splitting $input_file ($duration seconds) into $num_segments segments of approximately $segment_duration seconds each"

input_basename="$(basename "$input_file")"
input_extension="${input_basename##*.}"

ffmpeg                                                   \
    -nostdin                                             \
    -v                    $log_level                     \
    -i                    "$input_file"                  \
    -acodec               copy                           \
    -f                    segment                        \
    -vcodec               copy                           \
    -reset_timestamps     1                              \
    -segment_time         "$segment_duration"            \
    -segment_start_number 1                              \
    -segment_list         "$experiment_dir/segments.txt" \
    -segment_list_type    flat                           \
    "$experiment_dir/split/segment-%05d.$input_extension"
