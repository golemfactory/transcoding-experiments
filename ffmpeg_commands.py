import os
import subprocess
import datetime


FFMPEG_COMMAND = "ffmpeg"


######################################
##
def exec_cmd(cmd):
    pc = subprocess.Popen(cmd)
    return pc.wait()

######################################
##
def to_timestamp( seconds ):

    return str(datetime.timedelta(seconds=seconds))


######################################
##
def extract_video_part_command( input, output, start_time, end_time ):

    cmd = [ FFMPEG_COMMAND,
        "-ss", "{}".format( start_time ),
        "-i", "{}".format( input ),
        "-t", "{}".format( end_time - start_time ),
        "-c", "copy",
        output
    ]

    return cmd

######################################
##
def extract_video_part( input, output, start_time, end_time ):

    cmd = extract_video_part_command( input, output, start_time, end_time )
    exec_cmd( cmd )

