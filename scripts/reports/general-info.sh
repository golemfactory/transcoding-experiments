function general_info_report_header {
    printf "| video                                    | streams | format                  | duration |\n"
    printf "|------------------------------------------|---------|-------------------------|----------|\n"
}


function general_info_report_row {
    local video_file="$1"

    local video_basename="$(basename "$video_file")"
    local num_streams="$(ffprobe_show_entries "$video_file" format=nb_streams)"
    local format="$(     ffprobe_show_entries "$video_file" format=format_name)"
    local duration="$(   ffprobe_show_entries "$video_file" format=duration)"

    printf "| %-40s | %7s | %-23s | %8.0f |\n" "$video_basename" "$num_streams" "$format" "$duration"
}


function general_info_report {
    local files="$@"

    general_info_report_header
    for file in $files; do
        general_info_report_row "$file"
    done
}
