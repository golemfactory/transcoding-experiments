#!/bin/bash -e

input_file="$1"

frames=$(ffprobe -show_frames "$input_file" 2> /dev/null | grep "pict_type=" | sed 's/pict_type=\(.*\)$/\1/' | tr -d '\n')
echo "$frames"

echo "Frame count:   $(echo -n "$frames"                   | wc --chars)"
echo "I-frame count: $(echo -n "$frames" | sed 's/[^I]//g' | wc --chars)"
echo "P-frame count: $(echo -n "$frames" | sed 's/[^P]//g' | wc --chars)"
echo "B-frame count: $(echo -n "$frames" | sed 's/[^B]//g' | wc --chars)"
