import os
import subprocess
import datetime


FFMPEG_COMMAND = "ffmpeg"


######################################
##
def exec_cmd(cmd):

    print( "Executing command:" )
    print( cmd )

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
def generate_merge_list( input_files, output ):

    working_dir = os.getcwd()

    content = ""
    for file in input_files:
        file_abs_path = os.path.join( working_dir, file )
        content += "file '" + file_abs_path + "'\n"

    output_list_file = output + ".mergelist"

    with open(output_list_file, 'w') as file:
        file.write(content)

    return output_list_file
    

######################################
##
def merge_videos_command( input_files, output ):

    list_file = generate_merge_list( input_files, output )

    cmd = [ FFMPEG_COMMAND,
        "-f", "concat",
        "-safe", "0",
        "-i", list_file,
        "-c", "copy", output
    ]

    return cmd, list_file


######################################
##
def extract_video_part( input, output, start_time, end_time ):

    cmd = extract_video_part_command( input, output, start_time, end_time )
    exec_cmd( cmd )

######################################
##
def merge_videos( input_files, output ):

    cmd, list_file = merge_videos_command( input_files, output )
    exec_cmd( cmd )

    # remove temporary file with merge list
    #os.remove( list_file )


