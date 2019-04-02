function print_report_header {
    local columns="$@"

    printf "|"
    for column in $columns; do
        printf " "

        local header_variable="column_${column}[header]"
        local header="${!header_variable}"

        local length_variable="column_${column}[length]"
        local length="${!length_variable}"

        printf "%-${length}s |" "$header"
    done
    printf "\n"

    printf "|"
    for column in $columns; do
        printf "-"

        local length_variable="column_${column}[length]"
        local length="${!length_variable}"

        printf "%${length}s |" | tr " " "-"
    done
    printf "\n"
}


function print_report_row {
    local experiment_dir="$1"
    local columns="${@:2}"

    printf "|"
    for column in $columns; do
        printf " "

        local value_function_name="column_${column}_value"
        local value=$($value_function_name "$experiment_dir")

        format_variable="column_$column[format]"
        format="${!format_variable}"

        printf "$format |" "$value"
    done
    printf "\n"
}


function print_report {
    local experiment_set_dir="$1"
    local columns="${@:2}"

    local video_files="$(ls -1 "$experiment_set_dir")"

    print_report_header $columns

    for video_file in $video_files; do
        print_report_row "$experiment_set_dir/$video_file" $columns
    done
}
