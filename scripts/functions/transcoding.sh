function ffmpeg_scale {
    local scaling_factor="$1"
    local input_file="$2"
    local output_file="$3"

    echo "ffmpeg_scale: scale=$scaling_factor; input=$input_file; output=$output_file"

    ffmpeg                                                \
        -nostdin                                          \
        -hide_banner                                      \
        -i  "$input_file"                                 \
        -vf "scale=iw*$scaling_factor:ih*$scaling_factor" \
        "$output_file" 2> "$(strip_extension "$output_file")-ffmpeg-scale.log"
}


function ffmpeg_transcode_with_codec {
    local output_codec="$1"
    local input_file="$2"
    local output_file="$3"

    echo "ffmpeg_transcode_with_codec: codec=$output_codec; input=$input_file; output=$output_file"

    ffmpeg                                                \
        -nostdin                                          \
        -hide_banner                                      \
        -i  "$input_file"                                 \
        -vcodec "$output_codec"                           \
        "$output_file" 2> "$(strip_extension "$output_file")-ffmpeg-change-format.log"
}
