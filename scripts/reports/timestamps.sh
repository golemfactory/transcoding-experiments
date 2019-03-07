function timestamps_transcode_merge_report_header {
    printf "| video                                    | in duration  | out duration | mrg duration | in v start  | out v start | mrg v start | in a start  | out a start | mrg a start |\n"
    printf "|------------------------------------------|--------------|--------------|--------------|-------------|-------------|-------------|-------------|-------------|-------------|\n"
}


function timestamps_transcode_merge_report_row {
    local output_format="$1"
    local video_file="$2"
    local experiment_dir="$3"

    if [[ "$output_format" == "" ]]; then
        local output_format="$(get_extension "$video_file")"
    fi

    local video_basename="$(basename "$video_file")"
    local output_file="$experiment_dir/monolithic.$output_format"
    local merged_file="$experiment_dir/merged.$output_format"

    local input_duration="$( ffprobe_show_entries "$video_file"  format=duration)"
    local output_duration="$(ffprobe_show_entries "$output_file" format=duration)"
    local merged_duration="$(ffprobe_show_entries "$merged_file" format=duration)"

    local input_video_start_time="$( ffprobe_get_stream_attribute "$video_file"  v:0 start_time)"
    local output_video_start_time="$(ffprobe_get_stream_attribute "$output_file" v:0 start_time)"
    local merged_video_start_time="$(ffprobe_get_stream_attribute "$merged_file" v:0 start_time)"

    local input_audio_start_time="$( ffprobe_get_stream_attribute "$video_file"  a:0 start_time)"
    local output_audio_start_time="$(ffprobe_get_stream_attribute "$output_file" a:0 start_time)"
    local merged_audio_start_time="$(ffprobe_get_stream_attribute "$merged_file" a:0 start_time)"

    printf "| %-40s | %12s | %12s | %12s | %11s | %11s | %11s | %11s | %11s | %11s |\n" \
        "$video_basename"             \
        "$input_duration"             \
        "$output_duration"            \
        "$merged_duration"            \
        "$input_video_start_time"     \
        "$output_video_start_time"    \
        "$merged_video_start_time"    \
        "$input_audio_start_time"     \
        "$output_audio_start_time"    \
        "$merged_audio_start_time"
}


function timestamps_transcode_merge_report {
    local output_format="$1"
    local experiment_set_dir="$2"
    local video_files="$3"

    timestamps_transcode_merge_report_header
    for video_file in $video_files; do
        timestamps_transcode_merge_report_row "$output_format" "$video_file" "$experiment_set_dir/$(basename $video_file)"
    done
}
