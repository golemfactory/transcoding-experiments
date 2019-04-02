# VIDEO NAME

declare -A column_input_video_name
column_input_video_name[header]="video"
column_input_video_name[length]=40
column_input_video_name[format]=%-${column_input_video_name[length]}s


function column_input_video_name_value {
    local experiment_dir="$1"

    cat "$experiment_dir/video-name"
}


# NUM STREAMS

declare -A column_input_num_streams
column_input_num_streams[header]="streams"
column_input_num_streams[length]=7
column_input_num_streams[format]=%${column_input_num_streams[length]}d


function column_input_num_streams_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    ffprobe_show_entries "$input_file" format=nb_streams
}


# CODEC

declare -A column_input_video_codec
column_input_video_codec[header]="codec"
column_input_video_codec[length]=10
column_input_video_codec[format]=%-${column_input_video_codec[length]}s


function column_input_video_codec_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    ffprobe_get_stream_attribute "$input_file" v:0 codec_name
}


# FORMAT

declare -A column_input_video_format
column_input_video_format[header]="format"
column_input_video_format[length]=23
column_input_video_format[format]=%-${column_input_video_format[length]}s


function column_input_video_format_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    ffprobe_show_entries "$input_file" format=format_name
}


# FRAME COUNT

declare -A column_input_frame_count
column_input_frame_count[header]="in#"
column_input_frame_count[length]=5
column_input_frame_count[format]=%${column_input_frame_count[length]}d

function column_input_frame_count_value {
    local experiment_dir="$1"

    load_frame_count "$experiment_dir/input.$(cat "$experiment_dir/input-format")"
}


declare -A column_output_frame_count
column_output_frame_count[header]="out#"
column_output_frame_count[length]=5
column_output_frame_count[format]=%${column_output_frame_count[length]}d

function column_output_frame_count_value {
    local experiment_dir="$1"

    load_frame_count "$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
}


declare -A column_merged_frame_count
column_merged_frame_count[header]="mrg#"
column_merged_frame_count[length]=5
column_merged_frame_count[format]=%${column_merged_frame_count[length]}d

function column_merged_frame_count_value {
    local experiment_dir="$1"

    load_frame_count "$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
}


declare -A column_segment_frame_count
column_segment_frame_count[header]="splt in#"
column_segment_frame_count[length]=8
column_segment_frame_count[format]=%${column_segment_frame_count[length]}d

function column_segment_frame_count_value {
    local experiment_dir="$1"

    count_frames "$(frame_types_from_all_segments_side_by_side "$experiment_dir/split")"
}


declare -A column_transcoded_segment_frame_count
column_transcoded_segment_frame_count[header]="splt out#"
column_transcoded_segment_frame_count[length]=9
column_transcoded_segment_frame_count[format]=%${column_transcoded_segment_frame_count[length]}d

function column_transcoded_segment_frame_count_value {
    local experiment_dir="$1"

    count_frames "$(frame_types_from_all_segments_side_by_side "$experiment_dir/transcode/")"
}


# UNIQUE FRAME TYPES

declare -A column_input_unique_frame_types
column_input_unique_frame_types[header]="in type"
column_input_unique_frame_types[length]=7
column_input_unique_frame_types[format]=%${column_input_unique_frame_types[length]}s

function column_input_unique_frame_types_value {
    local experiment_dir="$1"

    load_unique_frame_types "$experiment_dir/input.$(cat "$experiment_dir/input-format")"
}


declare -A column_output_unique_frame_types
column_output_unique_frame_types[header]="out type"
column_output_unique_frame_types[length]=8
column_output_unique_frame_types[format]=%${column_output_unique_frame_types[length]}s

function column_output_unique_frame_types_value {
    local experiment_dir="$1"

    load_unique_frame_types "$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
}


declare -A column_merged_unique_frame_types
column_merged_unique_frame_types[header]="mrg type"
column_merged_unique_frame_types[length]=8
column_merged_unique_frame_types[format]=%${column_merged_unique_frame_types[length]}s

function column_merged_unique_frame_types_value {
    local experiment_dir="$1"

    load_unique_frame_types "$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
}


declare -A column_segment_unique_frame_types
column_segment_unique_frame_types[header]="splt in type"
column_segment_unique_frame_types[length]=12
column_segment_unique_frame_types[format]=%${column_segment_unique_frame_types[length]}s

function column_segment_unique_frame_types_value {
    local experiment_dir="$1"

    unique_frame_types "$(frame_types_from_all_segments_side_by_side "$experiment_dir/split")"
}


declare -A column_transcoded_segment_unique_frame_types
column_transcoded_segment_unique_frame_types[header]="splt out type"
column_transcoded_segment_unique_frame_types[length]=13
column_transcoded_segment_unique_frame_types[format]=%${column_transcoded_segment_unique_frame_types[length]}s

function column_transcoded_segment_unique_frame_types_value {
    local experiment_dir="$1"

    unique_frame_types "$(frame_types_from_all_segments_side_by_side "$experiment_dir/transcode/")"
}


# SAME FRAME TYPES

declare -A column_input_same_frame_types_as_segments
column_input_same_frame_types_as_segments[header]="in == splt in"
column_input_same_frame_types_as_segments[length]=13
column_input_same_frame_types_as_segments[format]=%${column_input_same_frame_types_as_segments[length]}s

function column_input_same_frame_types_as_segments_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    local input_frames="$(load_frame_types_for_video "$input_file")"
    local segment_frames="$(frame_types_from_all_segments_side_by_side "$experiment_dir/split")"

    if [[ "$input_frames" == "$segment_frames" ]]; then
        printf yes
    else
        printf no
    fi
}


declare -A column_segments_same_frame_types_as_merged
column_segments_same_frame_types_as_merged[header]="splt in == mrg"
column_segments_same_frame_types_as_merged[length]=14
column_segments_same_frame_types_as_merged[format]=%${column_segments_same_frame_types_as_merged[length]}s

function column_segments_same_frame_types_as_merged_value {
    local experiment_dir="$1"

    local segment_frames="$(frame_types_from_all_segments_side_by_side "$experiment_dir/split")"
    local merged_file="$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
    local merged_frames="$(load_frame_types_for_video "$merged_file")"

    if [[ "$segment_frames" == "$merged_frames" ]]; then
        printf yes
    else
        printf no
    fi
}


declare -A column_input_same_frame_types_as_output
column_input_same_frame_types_as_output[header]="in == out"
column_input_same_frame_types_as_output[length]=9
column_input_same_frame_types_as_output[format]=%${column_input_same_frame_types_as_output[length]}s

function column_input_same_frame_types_as_output_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    local input_frames="$(load_frame_types_for_video "$input_file")"
    local output_file="$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
    local output_frames="$(load_frame_types_for_video "$output_file")"

    if [[ "$input_frames" == "$output_frames" ]]; then
        printf yes
    else
        printf no
    fi
}


declare -A column_output_same_frame_types_as_merged
column_output_same_frame_types_as_merged[header]="out == mrg"
column_output_same_frame_types_as_merged[length]=10
column_output_same_frame_types_as_merged[format]=%${column_output_same_frame_types_as_merged[length]}s

function column_output_same_frame_types_as_merged_value {
    local experiment_dir="$1"

    local output_file="$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
    local output_frames="$(load_frame_types_for_video "$output_file")"
    local merged_file="$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
    local merged_frames="$(load_frame_types_for_video "$merged_file")"

    if [[ "$output_frames" == "$merged_frames" ]]; then
        printf yes
    else
        printf no
    fi
}


# I-FRAME COUNT

declare -A column_input_i_frame_count
column_input_i_frame_count[header]="#I in"
column_input_i_frame_count[length]=6
column_input_i_frame_count[format]=%${column_input_i_frame_count[length]}d

function column_input_i_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count I "$experiment_dir/input.$(cat "$experiment_dir/input-format")"
}


declare -A column_output_i_frame_count
column_output_i_frame_count[header]="#I out"
column_output_i_frame_count[length]=6
column_output_i_frame_count[format]=%${column_output_i_frame_count[length]}d

function column_output_i_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count I "$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
}


declare -A column_merged_i_frame_count
column_merged_i_frame_count[header]="#I mrg"
column_merged_i_frame_count[length]=6
column_merged_i_frame_count[format]=%${column_merged_i_frame_count[length]}d

function column_merged_i_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count I "$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
}


declare -A column_segment_i_frame_count
column_segment_i_frame_count[header]="#I splt in"
column_segment_i_frame_count[length]=10
column_segment_i_frame_count[format]=%${column_segment_i_frame_count[length]}d

function column_segment_i_frame_count_value {
    local experiment_dir="$1"

    count_frame_type I "$(frame_types_from_all_segments_side_by_side "$experiment_dir/split")"
}


declare -A column_transcoded_segment_i_frame_count
column_transcoded_segment_i_frame_count[header]="#I splt out"
column_transcoded_segment_i_frame_count[length]=11
column_transcoded_segment_i_frame_count[format]=%${column_transcoded_segment_i_frame_count[length]}d

function column_transcoded_segment_i_frame_count_value {
    local experiment_dir="$1"

    count_frame_type I "$(frame_types_from_all_segments_side_by_side "$experiment_dir/transcode/")"
}



# P-FRAME COUNT

declare -A column_input_p_frame_count
column_input_p_frame_count[header]="#P in"
column_input_p_frame_count[length]=6
column_input_p_frame_count[format]=%${column_input_p_frame_count[length]}d

function column_input_p_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count P "$experiment_dir/input.$(cat "$experiment_dir/input-format")"
}


declare -A column_output_p_frame_count
column_output_p_frame_count[header]="#P out"
column_output_p_frame_count[length]=6
column_output_p_frame_count[format]=%${column_output_p_frame_count[length]}d

function column_output_p_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count P "$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
}


declare -A column_merged_p_frame_count
column_merged_p_frame_count[header]="#P mrg"
column_merged_p_frame_count[length]=6
column_merged_p_frame_count[format]=%${column_merged_p_frame_count[length]}d

function column_merged_p_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count P "$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
}


declare -A column_segment_p_frame_count
column_segment_p_frame_count[header]="#P splt in"
column_segment_p_frame_count[length]=10
column_segment_p_frame_count[format]=%${column_segment_p_frame_count[length]}d

function column_segment_p_frame_count_value {
    local experiment_dir="$1"

    count_frame_type P "$(frame_types_from_all_segments_side_by_side "$experiment_dir/split")"
}


declare -A column_transcoded_segment_p_frame_count
column_transcoded_segment_p_frame_count[header]="#P splt out"
column_transcoded_segment_p_frame_count[length]=11
column_transcoded_segment_p_frame_count[format]=%${column_transcoded_segment_p_frame_count[length]}d

function column_transcoded_segment_p_frame_count_value {
    local experiment_dir="$1"

    count_frame_type P "$(frame_types_from_all_segments_side_by_side "$experiment_dir/transcode/")"
}


# B-FRAME COUNT

declare -A column_input_b_frame_count
column_input_b_frame_count[header]="#B in"
column_input_b_frame_count[length]=6
column_input_b_frame_count[format]=%${column_input_b_frame_count[length]}d

function column_input_b_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count B "$experiment_dir/input.$(cat "$experiment_dir/input-format")"
}


declare -A column_output_b_frame_count
column_output_b_frame_count[header]="#B out"
column_output_b_frame_count[length]=6
column_output_b_frame_count[format]=%${column_output_b_frame_count[length]}d

function column_output_b_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count B "$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
}


declare -A column_merged_b_frame_count
column_merged_b_frame_count[header]="#B mrg"
column_merged_b_frame_count[length]=6
column_merged_b_frame_count[format]=%${column_merged_b_frame_count[length]}d

function column_merged_b_frame_count_value {
    local experiment_dir="$1"

    load_frame_type_count B "$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
}


declare -A column_segment_b_frame_count
column_segment_b_frame_count[header]="#B splt in"
column_segment_b_frame_count[length]=10
column_segment_b_frame_count[format]=%${column_segment_b_frame_count[length]}d

function column_segment_b_frame_count_value {
    local experiment_dir="$1"

    count_frame_type B "$(frame_types_from_all_segments_side_by_side "$experiment_dir/split")"
}


declare -A column_transcoded_segment_b_frame_count
column_transcoded_segment_b_frame_count[header]="#B splt out"
column_transcoded_segment_b_frame_count[length]=11
column_transcoded_segment_b_frame_count[format]=%${column_transcoded_segment_b_frame_count[length]}d

function column_transcoded_segment_b_frame_count_value {
    local experiment_dir="$1"

    count_frame_type B "$(frame_types_from_all_segments_side_by_side "$experiment_dir/transcode/")"
}


# DURATION

declare -A column_input_duration_rounded
column_input_duration_rounded[header]="~in duration"
column_input_duration_rounded[length]=12
column_input_duration_rounded[format]=%${column_input_duration_rounded[length]}.0f

function column_input_duration_rounded_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    ffprobe_show_entries "$input_file" format=duration

}


declare -A column_input_duration
column_input_duration[header]="in duration"
column_input_duration[length]=11
column_input_duration[format]=%${column_input_duration[length]}s

function column_input_duration_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    ffprobe_show_entries "$input_file" format=duration

}


declare -A column_output_duration
column_output_duration[header]="out duration"
column_output_duration[length]=12
column_output_duration[format]=%${column_output_duration[length]}s

function column_output_duration_value {
    local experiment_dir="$1"

    local output_file="$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
    ffprobe_show_entries "$output_file" format=duration
}


declare -A column_merged_duration
column_merged_duration[header]="mrg duration"
column_merged_duration[length]=12
column_merged_duration[format]=%${column_merged_duration[length]}s

function column_merged_duration_value {
    local experiment_dir="$1"

    local merged_file="$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
    ffprobe_show_entries "$merged_file" format=duration
}


# VIDEO START TIME

declare -A column_input_video_start_time
column_input_video_start_time[header]="in v start"
column_input_video_start_time[length]=10
column_input_video_start_time[format]=%${column_input_video_start_time[length]}s

function column_input_video_start_time_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    ffprobe_get_stream_attribute "$input_file" v:0 start_time
}


declare -A column_output_video_start_time
column_output_video_start_time[header]="out v start"
column_output_video_start_time[length]=11
column_output_video_start_time[format]=%${column_output_video_start_time[length]}s

function column_output_video_start_time_value {
    local experiment_dir="$1"

    local output_file="$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
    ffprobe_get_stream_attribute "$output_file" v:0 start_time
}


declare -A column_merged_video_start_time
column_merged_video_start_time[header]="mrg v start"
column_merged_video_start_time[length]=11
column_merged_video_start_time[format]=%${column_merged_video_start_time[length]}s

function column_merged_video_start_time_value {
    local experiment_dir="$1"

    local merged_file="$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
    ffprobe_get_stream_attribute "$merged_file" v:0 start_time
}



# AUDIO START TIME

declare -A column_input_audio_start_time
column_input_audio_start_time[header]="in a start"
column_input_audio_start_time[length]=10
column_input_audio_start_time[format]=%${column_input_audio_start_time[length]}s

function column_input_audio_start_time_value {
    local experiment_dir="$1"

    local input_file="$experiment_dir/input.$(cat "$experiment_dir/input-format")"
    ffprobe_get_stream_attribute "$input_file" a:0 start_time
}


declare -A column_output_audio_start_time
column_output_audio_start_time[header]="out v start"
column_output_audio_start_time[length]=11
column_output_audio_start_time[format]=%${column_output_audio_start_time[length]}s

function column_output_audio_start_time_value {
    local experiment_dir="$1"

    local output_file="$experiment_dir/monolithic.$(cat "$experiment_dir/output-format")"
    ffprobe_get_stream_attribute "$output_file" a:0 start_time
}


declare -A column_merged_audio_start_time
column_merged_audio_start_time[header]="mrg v start"
column_merged_audio_start_time[length]=11
column_merged_audio_start_time[format]=%${column_merged_audio_start_time[length]}s

function column_merged_audio_start_time_value {
    local experiment_dir="$1"

    local merged_file="$experiment_dir/merged.$(cat "$experiment_dir/output-format")"
    ffprobe_get_stream_attribute "$merged_file" a:0 start_time
}
