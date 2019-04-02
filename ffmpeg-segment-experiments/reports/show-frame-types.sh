#!/bin/bash -e

source functions/all.sh

experiment_dir="$1"

input_format="$(cat "$experiment_dir/input-format")"
output_format="$(cat "$experiment_dir/output-format")"
input_file="$experiment_dir/input.$input_format"
merged_file="$experiment_dir/merged.$output_format"

input_frame_types="$(load_frame_types_for_video "$input_file")"
merged_frame_types="$(load_frame_types_for_video "$merged_file")"
segment_frame_types="$(frame_types_from_all_segments_side_by_side "$experiment_dir/split")"

echo "Frame types from '$experiment_dir'"
printf "Input video:\n%s\n"               "$input_frame_types"
printf "All segments side by side:\n%s\n" "$segment_frame_types"
printf "Merged video:\n%s\n"              "$merged_frame_types"
echo

if [[ "$input_frame_types" == "$segment_frame_types" ]]; then
    echo "Input video frame types vs segment frame types:  same"
else
    echo "Input video frame types vs segment frame types:  different"
fi

if [[ "$segment_frame_types" == "$merged_frame_types" ]]; then
    echo "Segment frame types vs merged video frame types: same"
else
    echo "Segment frame types vs merged video frame types: different"
fi
