#!/bin/bash -e

mkdir --parents number-frames/
mkdir --parents number-videos/

num_frames="$1"

function generate_frame {
    local frame_prefix="$1"
    local frame_number="$2"
    local width="$3"
    local height="$4"

    local dimensions=${width}x${height}
    local font_size=$(( height / 2 ))

    convert                     \
        -gravity    Center      \
        -background blue        \
        -fill       white       \
        -pointsize  $font_size  \
        label:$frame_number     \
        -extent     $dimensions \
        -quality    100         \
        "number-frames/$frame_prefix-$num_frames-$frame_number.png"
}

function generate_number_video {
    local frame_prefix="$1"
    local codec="$2"
    local format="$3"

    echo "Generating number-videos/numbers-$num_frames-$codec.$format"

    ffmpeg                                                       \
        -nostdin                                                 \
        -v      error                                            \
        -i      "number-frames/$frame_prefix-$num_frames-%d.png" \
        -vcodec "$codec"                                         \
        -strict -2                                               \
        "number-videos/numbers-$num_frames-$codec.$format"
}

echo "Generating $num_frames number frames"

# NOTE: The H.263 codec supports only a few specific resolutions. 352x288 is one of them.
for i in $(seq 1 "$num_frames"); do
    generate_frame default $i 128 128
done

generate_number_video default flv1       flv
generate_number_video h263    h263       3gp
generate_number_video default h264       mp4
generate_number_video default mpeg4      mpeg
generate_number_video default theora     ogv
generate_number_video default vp9        webm
generate_number_video default vp9        mp4
generate_number_video default wmv2       asf

