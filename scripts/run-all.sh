#!/bin/bash -e

if [[ "$1" == "--clear-output" ]]; then
    echo "Removing the output/ directory"
    rm -rf output/
fi

video_files="$(find input/ -mindepth 1 -maxdepth 1)"

./run-processing.sh 5 $video_files
./run-reports.sh $video_files
