function ffprobe_show_entries {
    local input_file="$1"
    local query="$2"

    printf "%s" $(
        ffprobe                                              \
            -v            error                              \
            -show_entries "$query"                           \
            -of           default=noprint_wrappers=1:nokey=1 \
            "$input_file"
    )
}


function ffprobe_show_entries_pretty {
    local input_file="$1"
    local query="$2"

    printf "%s" $(
        ffprobe                                              \
            -v            error                              \
            -pretty                                          \
            -show_entries "$query"                           \
            -of           default=noprint_wrappers=1:nokey=1 \
            "$input_file"
    )
}


function ffprobe_get_stream_attribute {
    local input_file="$1"
    local stream="$2"
    local attribute="$3"

    printf "%s" $(
        ffprobe                                                \
            -v              error                              \
            -select_streams "$stream"                          \
            -show_entries   "stream=$attribute"                \
            -of             default=noprint_wrappers=1:nokey=1 \
            "$input_file"
    )
}


function video_duration_in_seconds {
    local input_file="$1"

    ffprobe_show_entries "$input_file" "format=duration"
}


function approximate_segment_length {
    local duration="$1"
    local num_segments="$2"

    rounded_duration=$(printf "%.0f" "$duration")
    printf "%s" $((rounded_duration  / num_segments))
}


function frame_types {
    local input_file="$1"

    # NOTE: printf strips newlines and puts all characters on a single line. That's intentional.
    printf "%s" "$(ffprobe_show_entries "$input_file" frame=pict_type)"
}


function count_frames {
    local frames="$1"

    printf "%s" "$(
        printf "%s" "$frames" |
        wc --chars
    )"
}


function count_frame_type {
    local frame_type="$1"
    local frames="$2"

    printf "%s" "$(
        printf "%s" "$frames"       |
        sed 's/[^'$frame_type']//g' |
        wc --chars
    )"
}


function unique_frame_types {
    local frames="$1"

     printf "%s" "$(
         printf "%s" $frames |
         fold -w1            |
         sort --unique       |
         tr -d '\n'
     )"
}


function dump_frame_types_for_video {
    local video_file="$1"

    printf "%s" "$(frame_types "$video_file")" > "$(strip_extension "$video_file")-frame-types.txt"
}


function load_frame_types_for_video {
    local video_file="$1"

    cat "$(strip_extension "$video_file")-frame-types.txt"
}


function count_streams {
    codec_type="$1"
    input_file="$2"

    num_streams=$(ffprobe_show_entries "$input_file" format=nb_streams)

    result=0
    for i in $(seq 0 $(( $num_streams - 1 ))); do
        current_codec_type="$(ffprobe_get_stream_attribute "$input_file" $i codec_type)"

        if [[ "$current_codec_type" == "$codec_type" ]]; then
            result=$(( $result + 1 ))
        fi
    done

    printf "%d" $result
}
