#!/bin/bash -e
cd ../ffmpeg-segment-experiments
source functions/all.sh
cd ../scripts

input_file="$1"
output_dir="$2"

codec_format_pairs=(
    "flv1       flv"
    "h264       mp4"
    "hevc       mp4"
    "mjpeg      avi"
    "mpeg1video mpeg"
    "mpeg2video mpeg"
    "mpeg4      mpeg"
    "theora     ogv"
    "vp8        webm"
    "vp9        webm"
    "wmv1       asf"
    "wmv2       asf"

    # These are very slow. Let's put them last.
    "cinepak    cpk"
    "av1        mkv"
)

mkdir --parents "$output_dir"

function transcode {
    codec="$1"
    format="$2"
    input_file="$3"
    output_dir="$4"

    output_prefix=$(basename_without_extension $input_file)
    output_file="$output_dir/$output_prefix-$codec.$format"

    ffmpeg                           \
        -nostdin                     \
        -hide_banner                 \
        -v      error                \
        -i      "$input_file"        \
        -strict -2                   \
        -vcodec $codec               \
        -x265-params log-level=error \
        "$output_file" 2>&1 # 2>&1 redirects stderr to stdout
}

function time_and_print_to_stdout {
    { time "$@" ; } 3>&2 2>&1 1>&3
}

for pair in "${codec_format_pairs[@]}"; do
    codec_and_format=($pair)
    codec=${codec_and_format[0]}
    format=${codec_and_format[1]}

    timing=$(
        time_and_print_to_stdout \
            transcode            \
                $codec           \
                $format          \
                "$input_file"    \
                "$output_dir"    \
    )

    printf "%15s: " "$codec.$format"
    echo $timing
done
