import json
import m3u8
import os

# pylint: disable=import-error
from ffmpeg_commands import merge_videos, split_video, transcode_video
from m3u8_utils import create_and_dump_m3u8, join_playlists

OUTPUT_DIR = "/golem/output"
PARAMS_FILE = "params.json"


def do_split(path_to_stream, video_length, parts):
    split_file = split_video(path_to_stream, OUTPUT_DIR, video_length / parts)
    m3u8_main_list = m3u8.load(split_file)
    for segment in m3u8_main_list.segments:
        create_and_dump_m3u8(OUTPUT_DIR, segment)


def do_transcode(track, targs, output, use_playlist):
    transcode_video(track, targs, output, use_playlist)


def do_merge(outputfilename):
    playlists_dir = os.path.dirname(outputfilename)
    [output_playlist, _] = os.path.splitext(outputfilename)
    merged = join_playlists(playlists_dir)
    merged_filename = output_playlist + ".m3u8"
    file = open(merged_filename, 'w')
    file.write(merged.dumps())
    file.close()
    merge_videos(merged_filename, outputfilename)


def run():
    with open(PARAMS_FILE, 'r') as f:
        params = json.load(f)
        if int(params['context']) == 1:
            do_split(params['path_to_stream'], params['video_length'], params['parts'])
        elif int(params['context']) == 2:
            do_transcode(params['track'], params['targs'],
                         params['output_stream'], params['use_playlist'])
        elif int(params['context']) == 3:
            do_merge(params['output_stream'])


if __name__ == "__main__":
    run()
