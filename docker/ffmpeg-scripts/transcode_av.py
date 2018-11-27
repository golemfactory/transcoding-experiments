import os
import sys
import m3u8

import ffmpeg_commands as ffmpeg
from split_av import split_video_by_keyframes, split_video_ffmpeg_function
from m3u8_utils import create_and_dump_m3u8, join_playlists

WORK_DIR = "work"
RESOURCE_DIR = "resources"


def prepare_dirs(dir, res_dir, work_dir):

    if not os.path.isdir(dir):
        os.mkdir(dir)
    if not os.path.isdir(res_dir):
        os.mkdir(res_dir)
    if not os.path.isdir(work_dir):
        os.mkdir(work_dir)


def transcode(track, targs, output_dir):
    [basename, _] = os.path.splitext(track)
    output_playlist_name = os.path.join(output_dir, basename + "_TC.m3u8")
    ffmpeg.transcode_video(track, output_playlist_name, targs)

    return output_playlist_name


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
    m3u8_main_list = m3u8.load(split_file)
    counter = 0
    playlists = []
    transcode_playlist = []
    # for segment in m3u8_main_list.segments:
    #     playlists.append( create_and_dump_m3u8(res_dir, segment, counter) )
    #     counter += 1
    counter = 0
    # for track in playlists:
    #    transcode_playlist.append(transcode(track, targs, work_dir, counter))
    #    counter += 1
    merged = join_playlists(transcode_playlist)
    merged_filename = work_dir+"/merged_playlist.m3u8"
    file = open(merged_filename,'w')
    file.write(merged.dumps())
    file.close()
    
    ffmpeg.merge_videos(merged_filename, output_file)


if __name__ == "__main__":
    run()
