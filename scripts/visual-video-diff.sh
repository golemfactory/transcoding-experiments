#!/bin/bash -e

reference_file="$1"
new_file="$2"

ffplay                                      \
    -f lavfi                                \
    "                                       \
        movie=$reference_file[org];         \
        movie=$new_file[enc];               \
        [org][enc]blend=all_mode=difference
    "
