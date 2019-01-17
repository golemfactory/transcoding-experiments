import json
import m3u8
import shutil
import os

# pylint: disable=import-error
import ffmpeg_commands as ffmpeg
from m3u8_utils import create_and_dump_m3u8, join_playlists

OUTPUT_DIR = "/golem/output"
PARAMS_FILE = "params.json"


def do_split(path_to_stream, video_length, parts):
    split_file = ffmpeg.split_video(path_to_stream, OUTPUT_DIR, video_length / parts)
    m3u8_main_list = m3u8.load(split_file)
    for segment in m3u8_main_list.segments:
        create_and_dump_m3u8(OUTPUT_DIR, segment)


def do_transcode(track, targs, output, use_playlist):
    ffmpeg.transcode_video(track, targs, output, use_playlist)


def do_merge(playlists_dir, outputfilename):
    [output_playlist, _] = os.path.splitext(os.path.basename(outputfilename))
    merged = join_playlists(playlists_dir)
    merged_filename = os.path.join( "/golem/work/", output_playlist + ".m3u8" )
    file = open(merged_filename, 'w')
    file.write(merged.dumps())
    file.close()


    files = os.listdir(playlists_dir)
    for f in files:
        shutil.move(playlists_dir+f, "/golem/work/")

    ffmpeg.merge_videos(merged_filename, outputfilename)


def run():

    with open(PARAMS_FILE, 'r') as f:
        
        params = json.load(f)
        video_length = ffmpeg.get_video_len( params[ "path_to_stream" ] )

        if params['command'] == "split":
            do_split(params['path_to_stream'], video_length, params['parts'])
        elif params['command'] == "transcode":
            do_transcode(params['track'], params['targs'],
                         params['output_stream'], params['use_playlist'])
        elif params['command'] == "merge":
            do_merge("/golem/resources/", params['output_stream'])
        else:
            print("Invalid command.")


if __name__ == "__main__":
    run()
