function ffmpeg_scale {
    local scaling_factor="$1"
    local input_file="$2"
    local output_file="$3"

    echo "ffmpeg_scale: scale=$scaling_factor; input=$input_file; output=$output_file"

    # NOTE: `-v error` has no effect on the x265 encoder. It needs to be silenced separately via `-x265-params`.
    ffmpeg                                                         \
        -nostdin                                                   \
        -hide_banner                                               \
        -v           error                                         \
        -i           "$input_file"                                 \
        -vf          "scale=iw*$scaling_factor:ih*$scaling_factor" \
        -x265-params log-level=error                               \
        "$output_file"
}


function ffmpeg_transcode_with_codec {
    local output_codec="$1"
    local input_file="$2"
    local output_file="$3"

    echo "ffmpeg_transcode_with_codec: codec=$output_codec; input=$input_file; output=$output_file"

    # NOTE: `-v error` has no effect on the x265 encoder. It needs to be silenced separately via `-x265-params`.
    ffmpeg                           \
        -nostdin                     \
        -hide_banner                 \
        -v           error           \
        -i           "$input_file"   \
        -vcodec      "$output_codec" \
        -x265-params log-level=error \
        "$output_file"
}
