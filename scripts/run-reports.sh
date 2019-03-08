#!/bin/bash -e

source functions/all.sh

output_dir="$1"

echo "Input file info"
print_report "$output_dir/segment-split-only" ${report_input_file_info_columns[@]}
echo

echo "Timestamp report for segment-split-half-scale"
print_report "$output_dir/segment-split-half-scale" ${report_timestamps_transcode_merge_columns[@]}
echo

echo "Timestamp report for segment-split-vp9-convert"
print_report "$output_dir/segment-split-vp9-convert" ${report_timestamps_transcode_merge_columns[@]}
echo

echo "Timestamp report for segment-split-concat-protocol-merge-half-scale"
print_report "$output_dir/segment-split-concat-protocol-merge-half-scale" ${report_timestamps_transcode_merge_columns[@]}
echo

echo "Frame type report for segment-split-half-scale"
print_report "$output_dir/segment-split-half-scale" ${report_frame_types_with_transcoding_columns[@]}
echo

echo "Frame type report for segment-split-vp9-convert"
print_report "$output_dir/segment-split-vp9-convert" ${report_frame_types_with_transcoding_columns[@]}
echo

echo "Frame type report for segment-split-concat-protocol-merge-half-scale"
print_report "$output_dir/segment-split-concat-protocol-merge-half-scale" ${report_frame_types_with_transcoding_columns[@]}
echo

echo "Frame type report for segment-split-only"
print_report "$output_dir/segment-split-only" ${report_frame_types_without_transcoding_columns[@]}
echo

echo "Frame type comparison between input video, segment videos and merged video (split without transcoding)"
for video_file in $(ls -1 "$output_dir/segment-split-only"); do
    echo "================================================"
    experiment_dir="$output_dir/segment-split-only/$video_file"
    reports/show-frame-types.sh "$experiment_dir"
done
