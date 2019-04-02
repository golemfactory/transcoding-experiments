function run_experiment_on_all_videos {
    local num_segments="$1"
    local experiment_name="$2"
    local output_dir="$3"
    local video_files="${@:4}"

    mkdir --parents "$output_dir"

    for video_file in $video_files; do
        echo "Running experiment '$experiment_name' on $video_file"
        experiments/$experiment_name.sh "$num_segments" "$video_file" "$output_dir"
        echo
    done
}

function input_file_info_report {
    local output_dir="$1"
    local experiment_name="$2"

    echo "Input file info"
    print_report "$output_dir/$experiment_name" ${report_input_file_info_columns[@]}
    echo
}


function timestamps_report {
    local output_dir="$1"
    local experiment_name="$2"

    echo "Timestamp report for $experiment_name"
    print_report "$output_dir/$experiment_name" ${report_timestamps_transcode_merge_columns[@]}
    echo
}


function frame_type_report {
    local output_dir="$1"
    local experiment_name="$2"

    echo "Frame type report for $experiment_name"
    print_report "$output_dir/$experiment_name" ${report_frame_types_with_transcoding_columns[@]}
    echo
}


function frame_type_report_split_only {
    local output_dir="$1"
    local experiment_name="$2"

    echo "Frame type report for $experiment_name"
    print_report "$output_dir/$experiment_name" ${report_frame_types_without_transcoding_columns[@]}
    echo
}


function frame_type_dump_report {
    local output_dir="$1"
    local experiment_name="$2"

    echo "Frame type comparison between input video, segment videos and merged video (split without transcoding)"
    for video_file in $(ls -1 "$output_dir/$experiment_name"); do
        echo "================================================"
        local experiment_dir="$output_dir/$experiment_name/$video_file"
        reports/show-frame-types.sh "$experiment_dir"
    done
}
