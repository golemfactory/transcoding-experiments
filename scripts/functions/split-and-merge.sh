function ffmpeg_segment {
    local segment_duration="$1"
    local input_file="$2"
    local segment_name_pattern="$3"
    local segment_list_file="$4"

    echo "ffmpeg_segment: input=$input_file; duration=$segment_duration"

    ffmpeg                                                   \
        -nostdin                                             \
        -hide_banner                                         \
        -v                    error                          \
        -i                    "$input_file"                  \
        -acodec               copy                           \
        -f                    segment                        \
        -vcodec               copy                           \
        -reset_timestamps     1                              \
        -segment_time         "$segment_duration"            \
        -segment_start_number 1                              \
        -segment_list         "$segment_list_file"           \
        -segment_list_type    flat                           \
        "$segment_name_pattern"
}


function ffmpeg_concat {
    local ffconcat_segment_list_file="$1"
    local output_file="$2"

    echo "ffmpeg_concat: output=$output_file"

    ffmpeg                                  \
        -nostdin                            \
        -hide_banner                        \
        -v    error                         \
        -f    concat                        \
        -safe 0                             \
        -i    "$ffconcat_segment_list_file" \
        -c    copy                          \
        "$output_file"
}


function flat_file_list_to_ffconcat_list {
    local input_segment_list_file="$1"
    local output_segment_list_file="$2"

    echo -n "" > "$output_segment_list_file"
    cat "$input_segment_list_file" | while read -r segment_file_name; do
        printf "%s\n" "file '$segment_file_name'" >> "$output_segment_list_file"
    done
}


function rewrite_flat_file_list_with_different_format {
    local new_extension="$1"
    local input_segment_list_file="$2"
    local output_segment_list_file="$3"

    echo -n "" > "$output_segment_list_file"
    cat "$input_segment_list_file" | while read -r segment_file_name; do
        printf "%s\n" "$(strip_extension "$segment_file_name").$new_extension" >> "$output_segment_list_file"
    done
}


function split_with_ffmpeg_segment {
    local num_segments="$1"
    local input_file="$2"
    local output_dir="$3"

    echo "Splitting $input_file into approximately $num_segments segments"

    mkdir --parents $output_dir

    local video_duration="$(video_duration_in_seconds "$input_file")"
    local segment_duration=$(approximate_segment_length "$video_duration" "$num_segments")
    local extension=$(get_extension "$input_file")

    ffmpeg_segment                            \
        "$segment_duration"                   \
        "$input_file"                         \
        "$output_dir/segment-%05d.$extension" \
        "$output_dir/segments.txt"
}


function merge_with_ffmpeg_concat {
    local input_dir="$1"
    local output_dir="$2"
    local output_file_extension="$3"

    echo "Merging segments with ffmpeg concat"

    mkdir --parents "$output_dir"

    flat_file_list_to_ffconcat_list "$input_dir/segments.txt" "$input_dir/segments.ffconcat"
    ffmpeg_concat "$input_dir/segments.ffconcat" "$output_dir/merged.$output_file_extension"
}
