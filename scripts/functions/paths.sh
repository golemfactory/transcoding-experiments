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
