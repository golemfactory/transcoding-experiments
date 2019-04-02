#!/bin/bash -e

reference_file="$1"
new_file="$2"
output_dir="$3"

log_level=error

function mosaic {
    sequence_name="$1"
    work_dir="$2"

    montage                                                   \
        -geometry "+0+0"                                      \
        "$work_dir/$sequence_name-thumbnails/thumbnail-*.png" \
        "$work_dir/$sequence_name-mosaic.png"
}

function dump_thumbnails {
    sequence_name="$1"
    input_file="$2"
    work_dir="$3"

    mkdir -p "$work_dir/$sequence_name-thumbnails/"
    ffmpeg                    \
        -nostdin              \
        -hide_banner                                \
        -v  $log_level        \
        -i  "$input_file"     \
        -vf "scale=-1:100"    \
        "$work_dir/$sequence_name-thumbnails/thumbnail-%05d.png"
}

function dump_diff_thumbnails {
    reference_file="$1"
    new_file="$2"
    work_dir="$3"

    mkdir -p "$work_dir/diff-thumbnails/"
    ffmpeg                                          \
        -nostdin                                    \
        -hide_banner                                \
        -v  $log_level                              \
        -i  "$reference_file"                       \
        -i  "$new_file"                             \
        -filter_complex "                           \
            blend=all_mode=difference,              \
            scale=-1:100                            \
        "                                           \
        "$work_dir/diff-thumbnails/thumbnail-%05d.png"
}

echo "Dumping frames for the difference between the videos"
dump_diff_thumbnails "$reference_file" "$new_file" "$output_dir"

echo "Creating a mosaic of diff thumbnails in $output_dir/diff-mosaic.png"
mosaic diff "$output_dir"

echo "Dumping frame thumbnails for the reference video $reference_file"
dump_thumbnails reference "$reference_file" "$output_dir"

echo "Creating a mosaic of reference thumbnails in $output_dir/reference-mosaic.png"
mosaic reference "$output_dir"

echo "Dumping frame thumbnails for the new video $new_file"
dump_thumbnails new "$new_file" "$output_dir"

echo "Creating a mosaic of new thumbnails in $output_dir/new-mosaic.png"
mosaic new "$output_dir"
