#!/usr/bin/env bash

IMAGE=$1

function get_ssim() {
    docker run -it --rm --entrypoint ffmpeg \
    --mount type=bind,source="$(pwd)"/working-dir/mount/work/,target=/golem/work/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/output/,target=/golem/output/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/resources/,target=/golem/resources/ \
    ${IMAGE} \
    -i $1 \
    -i $2 \
    -lavfi \
    ssim=$3 -f null - | grep "SSIM" > $4
}

get_ssim $2 $3 $4 $5