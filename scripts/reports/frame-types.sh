function frame_types_report_header {
    printf "| video                                    | frames   | types | I-frames | P-frames | B-frames | duration |\n"
    printf "|------------------------------------------|----------|-------|----------|----------|----------|----------|\n"
}


function frame_types_report_row {
    local video_file="$1"

    local video_basename="$(basename "$video_file")"
    local frames="$(frame_types "$video_file")"
    local frame_count="$(count_frames "$frames")"
    local unique_frame_types="$(unique_frame_types "$frames")"
    local i_frame_count="$(count_frame_type I "$frames")"
    local p_frame_count="$(count_frame_type P "$frames")"
    local b_frame_count="$(count_frame_type B "$frames")"
    local duration="$(   ffprobe_show_entries "$video_file" format=duration)"

    printf "| %-40s | %8d | %5s | %8d | %8d | %8d | %8.0f |\n" "$video_basename" "$frame_count" "$unique_frame_types" "$i_frame_count" "$p_frame_count" "$b_frame_count" "$duration"
}


function frame_types_report {
    local files="$@"

    frame_types_report_header
    for file in $files; do
        frame_types_report_row "$file"
    done
}


function frame_types_merge_split_report_header {
    printf "| video                                    | in #   | splt # | mrg #  | in type   | splt type | mrg type  | in I#   | splt I# | mrg I#  | in P#   | splt P# | mrg P#  | in B#   | splt B# | mrg B#  | in == splt | splt == mrg |\n"
    printf "|------------------------------------------|--------|--------|--------|-----------|-----------|-----------|---------|---------|---------|---------|---------|---------|---------|---------|---------|------------|-------------|\n"
}


function frame_types_from_all_segments_side_by_side {
    local segment_dir="$1"

    segment_frame_types=""
    for segment_basename in $(cat "$segment_dir/segments.txt"); do
        segment_file="$segment_dir/$segment_basename"
        segment_frame_types="$segment_frame_types$(load_frame_types_for_video "$video_file")"
    done

    printf "%s" "$segment_frame_types"
}


function frame_types_merge_split_report_row {
    local video_file="$1"
    local experiment_dir="$2"

    local video_basename="$(basename "$video_file")"
    local output_format="$(get_extension "$video_file")"
    local merged_file="$experiment_dir/merged.$output_format"

    local input_frames="$(load_frame_types_for_video "$video_file")"
    local segment_frames="$(frame_types_from_all_segments_side_by_side "$experiment_dir/split/")"
    local merged_frames="$(load_frame_types_for_video "$merged_file")"

    local input_frame_count="$(  count_frames "$input_frames")"
    local segment_frame_count="$(count_frames "$segment_frames")"
    local merged_frame_count="$( count_frames "$merged_frames")"
    local input_unique_frame_types="$(  unique_frame_types "$input_frames")"
    local segment_unique_frame_types="$(unique_frame_types "$segment_frames")"
    local merged_unique_frame_types="$( unique_frame_types "$merged_frames")"
    local input_i_frame_count="$(  count_frame_type I "$input_frames")"
    local segment_i_frame_count="$(count_frame_type I "$segment_frames")"
    local merged_i_frame_count="$( count_frame_type I "$merged_frames")"
    local input_p_frame_count="$(  count_frame_type P "$input_frames")"
    local segment_p_frame_count="$(count_frame_type P "$segment_frames")"
    local merged_p_frame_count="$( count_frame_type P "$merged_frames")"
    local input_b_frame_count="$(  count_frame_type B "$input_frames")"
    local segment_b_frame_count="$(count_frame_type B "$segment_frames")"
    local merged_b_frame_count="$( count_frame_type B "$merged_frames")"

    if [[ "$input_frames" == "$segment_frames" ]]; then
        local input_equals_segments=yes
    else
        local input_equals_segments=no
    fi

    if [[ "$segment_frames" == "$merged_frames" ]]; then
        local segments_equal_merged=yes
    else
        local segments_equal_merged=no
    fi

    printf "| %-40s | %6d | %6d | %6d | %9s | %9s | %9s | %7d | %7d | %7d | %7d | %7d | %7d | %7d | %7d | %7d | %10s | %11s |\n" \
        "$video_basename"             \
        "$input_frame_count"          \
        "$segment_frame_count"        \
        "$merged_frame_count"         \
        "$input_unique_frame_types"   \
        "$segment_unique_frame_types" \
        "$merged_unique_frame_types"  \
        "$input_i_frame_count"        \
        "$segment_i_frame_count"      \
        "$merged_i_frame_count"       \
        "$input_p_frame_count"        \
        "$segment_p_frame_count"      \
        "$merged_p_frame_count"       \
        "$input_b_frame_count"        \
        "$segment_b_frame_count"      \
        "$merged_b_frame_count"       \
        "$input_equals_segments"      \
        "$segments_equal_merged"
}


function frame_types_merge_split_report {
    local experiment_set_dir="$1"
    local video_files="$2"

    frame_types_merge_split_report_header
    for video_file in $video_files; do
        frame_types_merge_split_report_row "$video_file" "$experiment_set_dir/$(basename $video_file)"
    done
}


function frame_types_transcode_merge_report_header {
    printf "| video                                    | in #   | out #  | mrg #  | in type   | out type  | mrg type  | in I#   | out I#  | mrg I#  | in P#   | out P#  | mrg P#  | in B#   | out B#  | mrg B#  | in == out | out == mrg |\n"
    printf "|------------------------------------------|--------|--------|--------|-----------|-----------|-----------|---------|---------|---------|---------|---------|---------|---------|---------|---------|-----------|------------|\n"
}


function frame_types_transcode_merge_report_row {
    local output_format="$1"
    local video_file="$2"
    local experiment_dir="$3"

    if [[ "$output_format" == "" ]]; then
        local output_format="$(get_extension "$video_file")"
    fi

    local video_basename="$(basename "$video_file")"
    local output_file="$experiment_dir/monolithic.$output_format"
    local merged_file="$experiment_dir/merged.$output_format"

    local input_frames="$(load_frame_types_for_video "$video_file")"
    local output_frames="$(load_frame_types_for_video "$output_file")"
    local merged_frames="$(load_frame_types_for_video "$merged_file")"

    local input_frame_count="$(  count_frames "$input_frames")"
    local output_frame_count="$(count_frames "$output_frames")"
    local merged_frame_count="$( count_frames "$merged_frames")"
    local input_unique_frame_types="$(  unique_frame_types "$input_frames")"
    local output_unique_frame_types="$(unique_frame_types "$output_frames")"
    local merged_unique_frame_types="$( unique_frame_types "$merged_frames")"
    local input_i_frame_count="$(  count_frame_type I "$input_frames")"
    local output_i_frame_count="$(count_frame_type I "$output_frames")"
    local merged_i_frame_count="$( count_frame_type I "$merged_frames")"
    local input_p_frame_count="$(  count_frame_type P "$input_frames")"
    local output_p_frame_count="$(count_frame_type P "$output_frames")"
    local merged_p_frame_count="$( count_frame_type P "$merged_frames")"
    local input_b_frame_count="$(  count_frame_type B "$input_frames")"
    local output_b_frame_count="$(count_frame_type B "$output_frames")"
    local merged_b_frame_count="$( count_frame_type B "$merged_frames")"

    if [[ "$input_frames" == "$output_frames" ]]; then
        local input_equals_output=yes
    else
        local input_equals_output=no
    fi

    if [[ "$output_frames" == "$merged_frames" ]]; then
        local output_equals_merged=yes
    else
        local output_equals_merged=no
    fi

    printf "| %-40s | %6d | %6d | %6d | %9s | %9s | %9s | %7d | %7d | %7d | %7d | %7d | %7d | %7d | %7d | %7d | %9s | %10s |\n" \
        "$video_basename"             \
        "$input_frame_count"          \
        "$output_frame_count"         \
        "$merged_frame_count"         \
        "$input_unique_frame_types"   \
        "$output_unique_frame_types"  \
        "$merged_unique_frame_types"  \
        "$input_i_frame_count"        \
        "$output_i_frame_count"       \
        "$merged_i_frame_count"       \
        "$input_p_frame_count"        \
        "$output_p_frame_count"       \
        "$merged_p_frame_count"       \
        "$input_b_frame_count"        \
        "$output_b_frame_count"       \
        "$merged_b_frame_count"       \
        "$input_equals_output"        \
        "$output_equals_merged"
}


function frame_types_transcode_merge_report {
    local output_format="$1"
    local experiment_set_dir="$2"
    local video_files="$3"

    frame_types_transcode_merge_report_header
    for video_file in $video_files; do
        frame_types_transcode_merge_report_row "$output_format" "$video_file" "$experiment_set_dir/$(basename $video_file)"
    done
}
