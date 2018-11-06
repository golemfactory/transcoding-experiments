import sys
import os

import ffmpeg_commands as ffmpeg
from split_av import split_video, split_video_by_keyframes, split_video_ffmpeg_function





######################################
##
def run():

    file_name = sys.argv[ 1 ]
    output_file = sys.argv[ 2 ]
    num_splits = int( sys.argv[ 3 ] )
    video_len = float( sys.argv[ 4 ] )       # We should read this from file

    output_dir = os.path.dirname( output_file )

    results = split_video_ffmpeg_function( file_name, output_dir, video_len / num_splits )
    #results, split_points = split_video_by_keyframes( file_name, output_dir, num_splits, video_len )
    print( results )
    #print( split_points )

    ffmpeg.merge_videos( results, output_file )


if __name__ == "__main__":
    run()


