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


function ffmpeg_input_ss {
    start_time="$1"
    end_time="$2"
    input_file="$3"
    output_file="$4"

    if [[ "$start_time" != "" ]]; then
        ss_option="-ss $start_time"
    else
        ss_option=""
    fi

    if [[ "$end_time" != "" ]]; then
        to_option="-to $end_time"
    else
        to_option=""
    fi

    echo "ffmpeg_input_ss: start=$start_time; end=$end_time; input=$input_file"

    ffmpeg                \
        -nostdin          \
        -hide_banner      \
        -v  error         \
        $ss_option        \
        $to_option        \
        -i  "$input_file" \
        -c  copy          \
        "$output_file"
}

function ffmpeg_input_ss_loop {
    local segment_duration="$1"
    local video_duration="$2"
    local input_file="$3"
    local segment_name_prefix="$4"
    local segment_format="$5"
    local segment_list_file="$6"

    printf "" > "$segment_list_file"

    local segment_index=1
    local start_time=""

    if (( $(echo "${segment_duration}>${video_duration}" | bc --mathlib) )); then
        local end_time="$video_duration"
    elif (( $(echo "${segment_duration}==0" | bc --mathlib) )); then
        local end_time="$video_duration"
    else
        local end_time="$segment_duration"
    fi

    while (( $(echo "${end_time}<${video_duration}" | bc --mathlib) )); do
        local segment_file="$(printf "%s-%05d.%s" "$segment_name_prefix" "$segment_index" "$segment_format")"
        printf "%s\n" "$(basename "$segment_file")" >> "$segment_list_file"

        ffmpeg_input_ss "$start_time" "$end_time" "$input_file" "$segment_file"

        segment_index=$(( $segment_index + 1 ))
        start_time="$end_time"
        end_time="$(echo "$end_time+$segment_duration" | bc --mathlib | sed 's/^\./0./')"
    done

    local segment_file="$(printf "%s-%05d.%s" "$segment_name_prefix" "$segment_index" "$segment_format")"
    printf "%s\n" "$(basename "$segment_file")" >> "$segment_list_file"

    ffmpeg_input_ss "$start_time" "" "$input_file" "$segment_file"
}


function ffmpeg_concat_demuxer {
    local ffconcat_segment_list_file="$1"
    local output_file="$2"

    echo "ffmpeg_concat_demuxer: output=$output_file"

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


function ffmpeg_concat_protocol {
    local segment_list_file="$1"
    local output_file="$2"

    joined_file_names="$(join_strings '|' $(cat "$segment_list_file"))"
    absolute_output_path="$(realpath "$output_file")"

    echo "ffmpeg_concat_protocol: output=$output_file"

    pushd "$(dirname "$segment_list_file")" > /dev/null
    ffmpeg                                \
        -nostdin                          \
        -hide_banner                      \
        -v    error                       \
        -i    "concat:$joined_file_names" \
        -c    copy                        \
        "$absolute_output_path"
    popd > /dev/null
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


function split_with_ffmpeg_input_ss {
    local num_segments="$1"
    local input_file="$2"
    local output_dir="$3"

    echo "Splitting $input_file into approximately $num_segments segments"

    mkdir --parents $output_dir

    local video_duration="$(video_duration_in_seconds "$input_file")"
    local segment_duration=$(approximate_segment_length "$video_duration" "$num_segments")
    local extension=$(get_extension "$input_file")

    ffmpeg_input_ss_loop      \
        "$segment_duration"   \
        "$video_duration"     \
        "$input_file"         \
        "$output_dir/segment" \
        "$extension"          \
        "$output_dir/segments.txt"
}


function merge_with_ffmpeg_concat_demuxer {
    local input_dir="$1"
    local output_dir="$2"
    local output_file_extension="$3"

    echo "Merging segments with ffmpeg concat demuxer"

    mkdir --parents "$output_dir"

    flat_file_list_to_ffconcat_list "$input_dir/segments.txt" "$input_dir/segments.ffconcat"
    ffmpeg_concat_demuxer "$input_dir/segments.ffconcat" "$output_dir/merged.$output_file_extension"
}


function merge_with_ffmpeg_concat_protocol {
    local input_dir="$1"
    local output_dir="$2"
    local output_file_extension="$3"

    echo "Merging segments with ffmpeg concat protocol"

    mkdir --parents "$output_dir"

    ffmpeg_concat_protocol "$input_dir/segments.txt" "$output_dir/merged.$output_file_extension"
}
