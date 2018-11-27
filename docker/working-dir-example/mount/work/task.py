import params
import m3u8
import os
from split_av import split_video_ffmpeg_function
from transcode_av import transcode
from ffmpeg_commands import merge_videos
from m3u8_utils import create_and_dump_m3u8, join_playlists

WORK_DIR = "/golem/work/"
OUTPUT_DIR = "/golem/output"

def split_stream(path_to_stream, video_length, parts):
    split_file = split_video_ffmpeg_function(path_to_stream, OUTPUT_DIR, video_length / parts)
    m3u8_main_list = m3u8.load(split_file)
    for segment in m3u8_main_list.segments:
        create_and_dump_m3u8(OUTPUT_DIR, segment)

def transcode_segment(playlist, targs):
       transcode(playlist, targs, OUTPUT_DIR)

def merge_stream(playlists, outputfilename):
    output_playlist = os.path.splitext(outputfilename)
    merged = join_playlists(playlists)
    merged_filename = WORK_DIR + output_playlist +".m3u8"
    file = open(merged_filename,'w')
    file.write(merged.dumps())
    file.close()
    merge_videos(merged_filename, outputfilename)

def run():
    #split_stream(params.path_to_stream, params.video_length, params.parts)
    transcode_segment(params.playlist, params.targs)

if __name__ == "__main__":
    run()
