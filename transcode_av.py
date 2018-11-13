import os
import sys

import ffmpeg_commands as ffmpeg
from split_av import split_video_by_keyframes, split_video_ffmpeg_function

WORK_DIR = "work"
RESOURCE_DIR = "resources"


def prepare_dirs(dir, res_dir, work_dir):

    if not os.path.isdir(dir):
        os.mkdir(dir)
    if not os.path.isdir(res_dir):
        os.mkdir(res_dir)
    if not os.path.isdir(work_dir):
        os.mkdir(work_dir)


def transcode(resources, work_dir):
    output = os.path.join(work_dir, "output.m3u8")
    ffmpeg.transcode_video(resources, output)

    return output


def run():
    file_name = sys.argv[1]
    output_file = sys.argv[2]
    num_splits = int(sys.argv[3])
    video_len = float(sys.argv[4])  # We should read this from file

    output_dir = os.path.dirname(output_file)
    res_dir = os.path.join(output_dir, RESOURCE_DIR)
    work_dir = os.path.join(output_dir, WORK_DIR)
    prepare_dirs(output_dir, res_dir, work_dir)

    split_file = split_video_ffmpeg_function(file_name, res_dir,  video_len / num_splits)
    transcode_file = transcode(split_file, work_dir)
    ffmpeg.merge_videos(transcode_file, output_file)


if __name__ == "__main__":
    run()
