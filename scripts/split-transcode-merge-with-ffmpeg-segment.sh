#!/bin/bash -e

input_file="$1"
output_dir="$2"
num_segments="$3"

log_level=error

mkdir -p "$output_dir/split/"
mkdir -p "$output_dir/transcoded/"

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
input_prefix="${input_basename%%.*}"
input_extension="${input_basename##*.}"
segment_list_file="$output_dir/transcoded/$input_prefix.ffconcat"
segment_name_pattern="$output_dir/split/$input_prefix-%5d.$input_extension"
merged_file_name="$output_dir/$input_prefix-merged-transcoded.$input_extension"

ffmpeg                                         \
    -nostdin                                   \
    -v                    $log_level           \
    -i                    "$input_file"        \
    -acodec               copy                 \
    -f                    segment              \
    -vcodec               copy                 \
    -reset_timestamps     1                    \
    -map                  0                    \
    -segment_time         "$segment_duration"  \
    -segment_start_number 1                    \
    -segment_list         "$segment_list_file" \
    -segment_list_type    ffconcat             \
    "$segment_name_pattern"

for segment_file_name in $(ls -1 "$output_dir/split/"); do
    echo "Transcoding $output_dir/split/$segment_file_name"

    ffmpeg                                         \
        -nostdin                                   \
        -v  $log_level                             \
        -i  "$output_dir/split/$segment_file_name" \
        -vf "scale=iw/2:ih/2"                      \
        "$output_dir/transcoded/$segment_file_name"
done

echo "Merging segments into $merged_file_name"
ffmpeg                                                 \
    -nostdin                                           \
    -v $log_level                                      \
    -f concat                                          \
    -safe                         0                    \
    -i "$output_dir/transcoded/$input_prefix.ffconcat" \
    -c copy                                            \
    "$merged_file_name"

echo "Transcoding the whole input file without splitting and merging"
ffmpeg                    \
    -nostdin              \
    -v  $log_level        \
    -i  "$input_file"     \
    -vf "scale=iw/2:ih/2" \
    "$output_dir/$input_prefix-transcoded.$input_extension"
