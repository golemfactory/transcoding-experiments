#!/bin/bash -e

mkdir --parents number-frames/
mkdir --parents number-videos/

num_frames="$1"
gop_size="$2"    # GOP = Group of Pictures; each GOP starts with an I-frame

if [[ "$gop_size" == "" ]]; then
    gop_size=25
fi

function generate_frame {
    local frame_prefix="$1"
    local frame_number="$2"
    local width="$3"
    local height="$4"

    local dimensions=${width}x${height}
    local font_size=$(( height / 2 ))

    convert                     \
        -gravity    Center      \
        -background blue        \
        -fill       white       \
        -pointsize  $font_size  \
        label:$frame_number     \
        -extent     $dimensions \
        -quality    100         \
        "number-frames/$frame_prefix-$num_frames-$frame_number.png"
}

function generate_number_video {
    local frame_prefix="$1"
    local codec="$2"
    local format="$3"

    echo "Generating number-videos/numbers-$num_frames-gop-$gop_size-$codec.$format"

    ffmpeg                                                       \
        -nostdin                                                 \
        -v      error                                            \
        -i      "number-frames/$frame_prefix-$num_frames-%d.png" \
        -vcodec "$codec"                                         \
        -g      "$gop_size"                                      \
        -strict -2                                               \
        "number-videos/numbers-$num_frames-gop-$gop_size-$codec.$format"
}

echo "Generating $num_frames number frames with GOP size $gop_size"

# NOTE: The H.263 codec supports only a few specific resolutions. 352x288 is one of them.
for i in $(seq 1 "$num_frames"); do
    generate_frame default $i 128 128
    generate_frame h263    $i 352 288   # Resolutions supported by h263:     128x96, 176x144, 352x288,   704x576, 1408x1152
    generate_frame dvvideo $i 720 576   # Resolutions supported by dvvideo: 720x480, 720x576, 960x720, 1280x1080, 1440x1080
done

# Tier 1: popular codecs
generate_number_video default av1        mkv   # Alliance for Open Media AV1
generate_number_video default cinepak    cpk   # Cinepak
generate_number_video default dirac      mkv   # Dirac
generate_number_video default dirac      mp4
generate_number_video default dirac      avi
generate_number_video default flv1       flv   # FLV / Sorenson Spark / Sorenson H.263 (Flash Video)
generate_number_video default flv1       mkv
generate_number_video default flv1       avi
generate_number_video h263    h263       3gp   # H.263 / H.263-1996, H.263+ / H.263-1998 / H.263 version 2
generate_number_video default h264       mp4   # H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10
generate_number_video default h264       mkv
generate_number_video default h264       avi
generate_number_video default h264       flv
generate_number_video default hevc       mp4   # H.265 / HEVC (High Efficiency Video Coding)
generate_number_video default hevc       mkv
generate_number_video default hevc       mpeg
generate_number_video default mjpeg      avi    # Motion JPEG
generate_number_video default mjpeg      mov
generate_number_video default mjpeg      mkv
generate_number_video default mpeg1video mpeg  # MPEG-1 video
generate_number_video default mpeg1video m1v
generate_number_video default mpeg2video mpeg  # MPEG-2 video
generate_number_video default mpeg4      mpeg  # MPEG-4 part 2
generate_number_video default mpeg4      mp4
generate_number_video default theora     ogv   # Theora
generate_number_video default theora     mkv
generate_number_video default vp8        webm  # On2 VP8
generate_number_video default vp8        ivf
generate_number_video default vp9        webm  # Google VP9
generate_number_video default vp9        mp4
generate_number_video default vp9        avi
generate_number_video default wmv1       asf   # Windows Media Video 7
generate_number_video default wmv2       asf   # Windows Media Video 8

# Tier 2: some less popular codecs
generate_number_video default huffyuv    mkv   # HuffYUV
generate_number_video default msmpeg4v2  avi  # MPEG-4 part 2 Microsoft variant version 2
generate_number_video default msmpeg4v2  wmv
generate_number_video default msmpeg4v3  avi  # MPEG-4 part 2 Microsoft variant version 3
generate_number_video default msmpeg4v3  wmv
generate_number_video default svq1       mov   # Sorenson Vector Quantizer 1 / Sorenson Video 1 / SVQ1
generate_number_video default v210       avi  # Uncompressed 4:2:2 10-bit
generate_number_video default v308       avi   # Uncompressed packed 4:4:4
generate_number_video default v408       avi   # Uncompressed packed QT 4:4:4:4
generate_number_video default v410       avi   # Uncompressed 4:4:4 10-bit
generate_number_video default y41p       avi   # Uncompressed YUV 4:1:1 12-bit
generate_number_video default yuv4       avi   # Uncompressed packed 4:2:0

# Tier 3: problematic codecs/containers.
# Splitting, merging or transcoding most of them ends with an error.
generate_number_video h263    h261      h261   # H.261
generate_number_video h263    h263      h263
generate_number_video h263    h263p     h263   # H.263+ / H.263-1998 / H.263 version 2
generate_number_video default h264      h264
generate_number_video default hevc      hevc
generate_number_video default mjpeg     mjpeg
generate_number_video default rv10      rm     # RealVideo 1.0
generate_number_video default rv20      rm     # RealVideo 2.0
generate_number_video default dirac     drc    #
generate_number_video default msmpeg4v2 mpeg   # MPEG-4 part 2 Microsoft variant version 2
generate_number_video default msmpeg4v3 mpeg   # MPEG-4 part 2 Microsoft variant version 3
generate_number_video default rawvideo  mkv    # raw video
generate_number_video dvvideo dvvideo   dv     # DV (Digital Video)
