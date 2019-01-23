#!/usr/bin/env bash

IMAGE=$1

function get_metadata() {
    docker run -it --rm --entrypoint ffprobe \
    --mount type=bind,source="$(pwd)"/working-dir/mount/work/,target=/golem/work/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/output/,target=/golem/output/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/resources/,target=/golem/resources/ \
    ${IMAGE} \
    -v quiet \
    -print_format json \
    -show_format \
    -show_streams $1 > $2
}

get_metadata $2 $3