mkdir --parents number-frames/
mkdir --parents number-videos/

num_frames="$1"

echo "Generating $num_frames number frames"

# NOTE: The H.263 codec supports only a few specific resolutions. 352x288 is one of them.
for i in $(seq 1 "$num_frames"); do
    convert                 \
        -gravity    Center  \
        -background blue    \
        -fill       white   \
        -pointsize  200     \
        label:$i            \
        -extent     352x288 \
        -quality    100     \
        "number-frames/$num_frames-$i.png"
done

function generate_number_video {
    local codec="$1"
    local format="$2"

    echo "Generating number-videos/numbers-$num_frames-$codec.$format"

    ffmpeg                                     \
        -nostdin                               \
        -v error                               \
        -i "number-frames/$num_frames-%d.png"  \
        -vcodec "$codec"                       \
        "number-videos/numbers-$num_frames-$codec.$format"
}

generate_number_video vp9    mp4
generate_number_video theora ogv
generate_number_video flv1   flv
generate_number_video mpeg4  mpeg
generate_number_video h264   mp4
generate_number_video vp9    webm
generate_number_video wmv2   asf
generate_number_video h263   3gp
