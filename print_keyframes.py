import sys
import os

import ffmpeg_commands as ffmpeg



######################################
##
def run():

    file_name = sys.argv[ 1 ]
    tmp_dir = os.path.dirname( file_name )

    keyframes = ffmpeg.list_keyframes( file_name, tmp_dir )
    
    print( "===================================================" )
    print( "Keyframes of file: " + file_name )
    print( keyframes )


if __name__ == "__main__":
    run()
