import sys
import os

import ffmpeg_commands as ffmpeg
from split_av import split_video





######################################
##
def run():

    file_name = sys.argv[ 1 ]
    output_file = sys.argv[ 2 ]
    num_splits = int( sys.argv[ 3 ] )
    video_len = float( sys.argv[ 4 ] )       # We should read this from file

    output_dir = os.path.dirname( output_file )

    keyframes = ffmpeg.list_keyframes( file_name, output_dir )
    print( keyframes )

    results = split_video( file_name, output_dir, num_splits, video_len )
    print( results )

    ffmpeg.merge_videos( results, output_file )


if __name__ == "__main__":
    run()


