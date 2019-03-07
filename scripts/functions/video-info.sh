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

    printf "%s" "$(
        ffprobe -show_frames "$input_file" 2> /dev/null |
        grep "pict_type="                               |
        sed 's/pict_type=\(.*\)$/\1/'                   |
        tr -d '\n'
    )"
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
