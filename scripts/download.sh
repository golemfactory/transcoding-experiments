#!/bin/bash -e

output_dir="$1"

function get_extension {
    local file_path="$1"

    local file_basename="$(basename "$file_path")"
    local file_extension="${file_basename##*.}"

    printf "%s" $file_extension
}


function strip_extension {
    local file_path="$1"

    printf "%s" "${file_path%.*}"
}


function basename_without_extension {
    local file_path="$1"

    local path_without_extension="$(strip_extension "$file_path")"
    printf "%s" "$(basename "$path_without_extension")"
}

urls=(
    "http://mirrors.standaloneinstaller.com/video-sample/grb_2.flv"
    "https://sample-videos.com/video123/3gp/144/big_buck_bunny_144p_1mb.3gp"
)

mkdir --parents "$output_dir/downloaded/"
mkdir --parents "$output_dir/renamed/"

for url in ${urls[@]}; do
    original_name="$(basename "$url")"
    curl "$url" --output "$output_dir/downloaded/$original_name"
    meta_name="$(./build-name.sh "$output_dir/downloaded/$original_name")"
    ln "$output_dir/downloaded/$original_name" "$output_dir/renamed/$meta_name.$(get_extension "$original_name")"
done
