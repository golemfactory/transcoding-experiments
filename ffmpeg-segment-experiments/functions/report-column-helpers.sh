function load_frame_count {
    local video_file="$1"

    local frames="$(load_frame_types_for_video "$video_file")"
    printf "%s" "$(count_frames "$frames")"
}


function load_frame_type_count {
    local frame_type="$1"
    local video_file="$2"

    local frames="$(load_frame_types_for_video "$video_file")"
    printf "%s" "$(count_frame_type "$frame_type" "$frames")"
}


function load_unique_frame_types {
    local video_file="$1"

    local frames="$(load_frame_types_for_video "$video_file")"
    printf "%s" "$(unique_frame_types "$frames")"
}


function frame_types_from_all_segments_side_by_side {
    local segment_dir="$1"

    segment_frame_types=""
    for segment_basename in $(cat "$segment_dir/segments.txt"); do
        segment_file="$segment_dir/$segment_basename"
        segment_frame_types="$segment_frame_types$(load_frame_types_for_video "$segment_file")"
    done

    printf "%s" "$segment_frame_types"
}
