#!/usr/bin/env bash

IMAGE=$1

function print_keyframes() {
     docker run -it --rm --entrypoint ffprobe \
    --mount type=bind,source="$(pwd)"/working-dir/mount/work/,target=/golem/work/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/output/,target=/golem/output/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/resources/,target=/golem/resources/ \
    ${IMAGE} \
    -loglevel quiet \
    -skip_frame nokey \
    -select_streams v:0 \
    -show_entries frame=pkt_pts_time \
    -of csv=print_section=0 $1
}

print_keyframes $2