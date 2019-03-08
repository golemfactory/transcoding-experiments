#!/bin/bash -e

source functions/all.sh
source reports/all.sh

video_files="$@"

echo "General info report"
general_info_report $video_files
echo

echo "Timestamp report for segment-split-half-scale"
timestamps_transcode_merge_report "" output/segment-split-half-scale "$video_files"
echo

echo "Timestamp report for segment-split-vp9-convert"
timestamps_transcode_merge_report mkv output/segment-split-vp9-convert "$video_files"
echo

echo "Frame type (input, output, merged) report for segment-split-half-scale"
frame_types_transcode_merge_report "" output/segment-split-half-scale "$video_files"
echo

echo "Frame type (input, output, merged) report for segment-split-vp9-convert"
frame_types_transcode_merge_report mkv output/segment-split-vp9-convert "$video_files"
echo

echo "Frame type (input, segments, merged) report for segment-split-only"
frame_types_merge_split_report output/segment-split-only "$video_files"
echo

echo "Frame type report for segment-split-half-scale"
frame_types_merge_split_report output/segment-split-half-scale "$video_files"
echo

echo "Frame type report"
frame_types_report  $video_files
echo

echo "Frame type comparison between input video, segment videos and merged video (split without transcoding)"
for video_file in $video_files; do
    echo "================================================"
    experiment_dir="output/segment-split-only/$video_file"
    reports/show-frame-types.sh "$experiment_dir"
done
