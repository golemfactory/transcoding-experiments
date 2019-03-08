#!/bin/bash -e

source functions/all.sh

output_dir="$1"

echo "General info report"
columns=(
    input_video_name
    input_num_streams
    input_video_format
    input_video_codec
    input_duration_rounded
)
print_report "$output_dir/segment-split-only" ${columns[@]}
echo

echo "Timestamp report for segment-split-half-scale"
timestamps_transcode_merge_columns=(
    input_video_name
    input_duration
    output_duration
    merged_duration
    input_video_start_time
    output_video_start_time
    merged_video_start_time
    input_audio_start_time
    output_audio_start_time
    merged_audio_start_time
)
print_report "$output_dir/segment-split-half-scale" ${timestamps_transcode_merge_columns[@]}
echo

echo "Timestamp report for segment-split-vp9-convert"
print_report "$output_dir/segment-split-vp9-convert" ${timestamps_transcode_merge_columns[@]}
echo

echo "Frame type (input, output, merged) report for segment-split-half-scale"
frame_types_transcode_merge_columns=(
    input_video_name
    input_frame_count
    output_frame_count
    merged_frame_count
    input_unique_frame_types
    output_unique_frame_types
    merged_unique_frame_types
    input_i_frame_count
    output_i_frame_count
    merged_i_frame_count
    input_p_frame_count
    output_p_frame_count
    merged_p_frame_count
    input_b_frame_count
    output_b_frame_count
    merged_b_frame_count
    input_same_frame_types_as_output
    output_same_frame_types_as_merged
)
print_report "$output_dir/segment-split-half-scale" ${frame_types_transcode_merge_columns[@]}
echo

echo "Frame type (input, output, merged) report for segment-split-vp9-convert"
print_report "$output_dir/segment-split-vp9-convert" ${frame_types_transcode_merge_columns[@]}
echo

echo "Frame type (input, segments, merged) report for segment-split-only"
frame_types_merge_split_columns=(
    input_video_name
    input_frame_count
    segment_frame_count
    merged_frame_count
    input_unique_frame_types
    segment_unique_frame_types
    merged_unique_frame_types
    input_i_frame_count
    segment_i_frame_count
    merged_i_frame_count
    input_p_frame_count
    segment_p_frame_count
    merged_p_frame_count
    input_b_frame_count
    segment_b_frame_count
    merged_b_frame_count
    input_same_frame_types_as_segments
    segments_same_frame_types_as_merged
)
print_report "$output_dir/segment-split-only" ${frame_types_merge_split_columns[@]}
echo

echo "Frame type report for segment-split-half-scale"
print_report "$outputdir/segment-split-half-scale" ${frame_types_merge_split_columns[@]}
echo

echo "Frame type report"
frame_types_columns=(
    input_video_name
    input_frame_count
    input_unique_frame_types
    input_i_frame_count
    input_p_frame_count
    input_b_frame_count
    input_duration_rounded
)
print_report "$output_dir/segment-split-only" ${frame_types_columns[@]}
echo


echo "Frame type comparison between input video, segment videos and merged video (split without transcoding)"
for video_file in $(ls -1 "$output_dir/segment-split-only"); do
    echo "================================================"
    experiment_dir="$output_dir/segment-split-only/$video_file"
    reports/show-frame-types.sh "$experiment_dir"
done
