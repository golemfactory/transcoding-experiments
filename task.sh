#!/usr/bin/env bash

IMAGE=$1

function run_docker_task() {
    docker run -it --rm \
    --mount type=bind,source="$(pwd)"/working-dir/mount/work/,target=/golem/work/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/output/,target=/golem/output/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/resources/,target=/golem/resources/ \
    ${IMAGE} \
    task.py
}

run_docker_task