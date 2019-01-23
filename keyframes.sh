#!/usr/bin/env bash

ffprobe -loglevel quiet -skip_frame nokey -select_streams v:0 -show_entries frame=pkt_pts_time -of csv=print_section=0 $1
