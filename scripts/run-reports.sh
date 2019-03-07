#!/bin/bash -e

source functions/all.sh

video_files="$@"

for video_file in $video_files; do
    echo "================================================"
    reports/show-frame-types.sh segment-split-only "$video_file"
done
