#!/bin/bash -e

cd $(dirname ${BASH_SOURCE[0]})

mkdir --parents output/

source config.sh

for video in ${videos[@]}; do
    for experiment in "${experiments[@]}"; do
        experiment_parameters=($experiment)
        experiment_name="$video-${experiment_parameters[0]}"
        split_command="commands/${experiment_parameters[1]}"
        transcode_command="commands/${experiment_parameters[2]}"
        merge_command="commands/${experiment_parameters[3]}"

        mkdir --parents output/$experiment_name/{split,transcode}/

        $split_command input/$video output/$experiment_name $num_segments

        for segment in $(find output/$experiment_name/split/ -mindepth 1 -maxdepth 1); do
            $transcode_command $segment output/$experiment_name
        done

        $merge_command output/$experiment_name
    done
done
