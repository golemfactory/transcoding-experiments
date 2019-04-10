#!/bin/bash -e

input_file="$1"
#output_dir="$2"
#num_segments="$3"

log_level=error

#mkdir -p "$output_dir"

duration=$(
    ffprobe                                              \
        -v            $log_level                         \
        -show_entries format=duration                    \
        -of           default=noprint_wrappers=1:nokey=1 \
        "$input_file"
)
video_codec=$(
    ffprobe                                              \
        -v            $log_level                         \
        -select_streams "v:0"                        \
        -show_entries stream=codec_name                  \
        -of           default=noprint_wrappers=1:nokey=1 \
        "$input_file"
)
frame_rate=$(
    ffprobe                                              \
        -v            $log_level                         \
        -select_streams "v:0"                        \
        -show_entries stream=r_frame_rate                  \
        -of           default=noprint_wrappers=1:nokey=1 \
        "$input_file"
)
frame_rate_float=$(
    python -c "print($frame_rate)"
)
width=$(
    ffprobe                                              \
        -v            $log_level                         \
        -select_streams "v:0"                        \
        -show_entries stream=width                  \
        -of           default=noprint_wrappers=1:nokey=1 \
        "$input_file"
)
height=$(
    ffprobe                                              \
        -v            $log_level                         \
        -select_streams "v:0"                        \
        -show_entries stream=height                  \
        -of           default=noprint_wrappers=1:nokey=1 \
        "$input_file"
)
#rounded_duration=$(printf "%.0f" "$duration")
#segment_duration=$((rounded_duration  / num_segments))
#echo "Splitting $input_file ($duration seconds) into $num_segments segments of approximately $segment_duration seconds each"

frames=$(ffprobe -show_frames "$input_file" 2> /dev/null | grep "pict_type=" | sed 's/pict_type=\(.*\)$/\1/' | tr -d '\n')

echo "Frame count:   $(echo -n "$frames"                   | wc --chars)"
echo "I-frame count: $(echo -n "$frames" | sed 's/[^I]//g' | wc --chars)"
echo "P-frame count: $(echo -n "$frames" | sed 's/[^P]//g' | wc --chars)"
echo "B-frame count: $(echo -n "$frames" | sed 's/[^B]//g' | wc --chars)"

frame_count="$(echo -n "$frames"                   | wc --chars)"
i_frame_count="$(echo -n "$frames" | sed 's/[^I]//g' | wc --chars)"
p_frame_count="$(echo -n "$frames" | sed 's/[^P]//g' | wc --chars)"
b_frame_count="$(echo -n "$frames" | sed 's/[^B]//g' | wc --chars)"

#ffprobe -show_entries stream=codec_type -select_streams v -of default=noprint_wrappers=1:nokey=1 -hide_banner -v error "$input_file" | wc -l
#ffprobe -show_entries stream=codec_type -select_streams a -of default=noprint_wrappers=1:nokey=1 -hide_banner -v error "$input_file" | wc -l
#ffprobe -show_entries stream=codec_type -select_streams s -of default=noprint_wrappers=1:nokey=1 -hide_banner -v error "$input_file" | wc -l

printf "%s,%sx%s,%.0fs,i%dp%db%d\n" "$video_codec" "$width" "$height" "$duration" "$i_frame_count" "$p_frame_count" "$b_frame_count"

#input_basename="$(basename "$input_file")"
#input_prefix="${input_basename%%.*}"
#input_extension="${input_basename##*.}"
#segment_name_pattern="$output_dir/$input_prefix-%5d.$input_extension"

#ffmpeg                                         \
#    -nostdin                                   \
#    -v                    $log_level           \
#    -i                    "$input_file"        \
#    -acodec               copy                 \
#    -f                    segment              \
#    -vcodec               copy                 \
#    -reset_timestamps     1                    \
#    -map                  0                    \
#    -segment_time         "$segment_duration"  \
#    -segment_start_number 1                    \
#    "$segment_name_pattern"
#
#for segment_file_name in $(ls -1 "$output_dir"); do
#    frames=$(ffprobe -show_frames "$output_dir/$segment_file_name" 2> /dev/null | grep "pict_type=" | sed 's/pict_type=\(.*\)$/\1/' | tr -d '\n')
#
#    frame_count="$(echo -n "$frames"                   | wc --chars)"
#    i_frame_count="$(echo -n "$frames" | sed 's/[^I]//g' | wc --chars)"
#    p_frame_count="$(echo -n "$frames" | sed 's/[^P]//g' | wc --chars)"
#    b_frame_count="$(echo -n "$frames" | sed 's/[^B]//g' | wc --chars)"
#
#    printf "i%dp%db%d\n" "$i_frame_count" "$p_frame_count" "$b_frame_count"
#
#done
