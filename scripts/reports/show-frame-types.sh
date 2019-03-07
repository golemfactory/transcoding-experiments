#!/bin/bash -e

source functions/all.sh

experiment_name="$1"
video_file="$2"

video_basename="$(basename "$video_file")"
experiment_dir="output/$experiment_name/$video_basename"
output_format="$(get_extension "$video_file")"
merged_file="$experiment_dir/merged.$output_format"

input_frame_types="$(frame_types "$video_file")"
merged_frame_types="$(frame_types "$merged_file")"

segment_frame_types=""
for segment_basename in $(cat "$experiment_dir/split/segments.txt"); do
    segment_file="$experiment_dir/split/$segment_basename"
    segment_frame_types="$segment_frame_types$(frame_types "$segment_file")"
done

echo "Frame types from experiment '$experiment_name' on $video_file"
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
