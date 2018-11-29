import params
import m3u8
import os
from ffmpeg_commands import merge_videos, split_video, transcode_video
from m3u8_utils import create_and_dump_m3u8, join_playlists

OUTPUT_DIR = "/golem/output"

def split_stream(path_to_stream, video_length, parts):
    split_file = split_video(path_to_stream, OUTPUT_DIR, video_length / parts)
    m3u8_main_list = m3u8.load(split_file)
    for segment in m3u8_main_list.segments:
        create_and_dump_m3u8(OUTPUT_DIR, segment)
    os.remove(split_file)

def transcode_segment(playlist, targs):
       transcode_video(playlist, targs, OUTPUT_DIR)

def merge_stream(playlists_dir, outputfilename):
    [output_playlist, _] = os.path.splitext(outputfilename)
    merged = join_playlists(playlists_dir)
    merged_filename = output_playlist +".m3u8"
    file = open(merged_filename,'w')
    file.write(merged.dumps())
    file.close()
    merge_videos(merged_filename, outputfilename)

def run():

    if params.context == 1:
        split_stream(params.path_to_stream, params.video_length, params.parts)
    elif params.context == 2:
        transcode_segment(params.playlist, params.targs)
    elif params.context == 3:
        merge_stream(params.playlists_dir, params.output_stream)

if __name__ == "__main__":
    run()
