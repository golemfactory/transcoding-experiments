# WARNING: Avoid using spaces in names and identfiers here.
# These scripts are very rudimentary and won't handle it well.

num_segments=3

# These files should be placed in the input/ directory
videos=(
    grb_2.m4v
    'big-buck-bunny-[codec=theora].ogv'
    'big-bunny-[codec=flv1].flv'
    # FIXME: These two files do not work
    #'carphone_qcif-[codec=rawvideo].y4m'        # "Unsupported codec"
    #'Dance-[codec=mpeg2video].mpeg'             # "Error while opening encoder for output stream #0:0" in resize-half
    'ForBiggerBlazes-[codec=h264].mp4'
    'ForBiggerMeltdowns-[codec=mpeg4].mp4'
    'Panasonic-[codec=vp9].webm'
    'star_trails-[codec=wmv2].wmv'
    'TRA3106-[codec=h263].3gp'
    Beach.mp4
    byger-liten.avi
    tortoise.mp4
    gada.mp4
)

# Items in each row: name, split command, transform command, merge command.
# The name is only used for display - as a short and unambiguous way to refer to this sequence of transformations.
# The scripts must be present in the commands/ subdirectory.
experiments=(
    "segment-vp9            split-segment.sh  convert-vp9.sh    merge-concat.sh"
    "segment-resize-half    split-segment.sh  resize-half.sh    merge-concat.sh"
    "segment-no-transcoding split-segment.sh  no-transcoding.sh merge-concat.sh"
)
