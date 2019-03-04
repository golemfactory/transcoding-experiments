#!/bin/bash -e

reference_file="$1"
new_file="$2"

ffmpeg                            \
    -hide_banner                  \
    -i "$reference_file"          \
    -i "$new_file"                \
    -lavfi  "ssim;[0:v][1:v]psnr" \
    -f null                       \
    -
