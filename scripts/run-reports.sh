#!/bin/bash -e

source functions/all.sh

output_dir="$1"

input_file_info_report       "$output_dir" segment-split-only

timestamps_report            "$output_dir" segment-split-half-scale
timestamps_report            "$output_dir" ss-split-half-scale
timestamps_report            "$output_dir" segment-split-vp9-convert
timestamps_report            "$output_dir" segment-split-concat-protocol-merge-half-scale

frame_type_report            "$output_dir" segment-split-half-scale
frame_type_report            "$output_dir" ss-split-half-scale
frame_type_report            "$output_dir" segment-split-vp9-convert
frame_type_report            "$output_dir" segment-split-concat-protocol-merge-half-scale

frame_type_report_split_only "$output_dir" segment-split-only
frame_type_report_split_only "$output_dir" ss-split-only

frame_type_dump_report       "$output_dir" segment-split-only
