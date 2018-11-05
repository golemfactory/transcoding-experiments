import os
import subprocess
import datetime


FFMPEG_COMMAND = "ffmpeg"
FFPROBE_COMMAND = "ffprobe"


######################################
##
def exec_cmd(cmd, file=None):

    print( "Executing command:" )
    print( cmd )

    pc = subprocess.Popen(cmd, stdout=file)
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
        # "-noaccurate_seek",
        "-i", "{}".format( input ),
        "-t", "{}".format( end_time - start_time ),
        "-c", "copy",# "-copyts",
        "-avoid_negative_ts", "1",
        output
    ]

    return cmd

######################################
##
def split_video_command( input, output, segment_time ):

    output_list_file = output

    cmd = [ FFMPEG_COMMAND,
        "-i", input,
        "-c:v", "h264",
        "-flags", "+cgop", "-g", "30",
        "-hls_time", "{}".format( segment_time ),
        output_list_file
    ]

    return cmd, output_list_file

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
def list_keyframes_command( input ):

    cmd = [ FFPROBE_COMMAND,
        "-loglevel", "quiet",
        "-skip_frame", "nokey",
        "-select_streams", "v:0",
        "-show_entries", "frame=pkt_pts_time",
        "-of", "csv=print_section=0",
        input
    ]

    return cmd

######################################
##
def extract_video_part( input, output, start_time, end_time ):

    cmd = extract_video_part_command( input, output, start_time, end_time )
    exec_cmd( cmd )

######################################
##
def split_video( input, output, segment_time ):

    cmd, file_list = split_video_command( input, output, segment_time )
    exec_cmd( cmd )

    return file_list

######################################
##
def merge_videos( input_files, output ):

    cmd, list_file = merge_videos_command( input_files, output )
    exec_cmd( cmd )

    # remove temporary file with merge list
    os.remove( list_file )

######################################
##
def list_keyframes( input, tmp_dir ):

    keyframes = []

    # Prepare temporary file with keyframes list.
    [ _, filename ] = os.path.split( input )
    keyframes_list_file = os.path.join( tmp_dir, filename + ".keyframes" )

    cmd = list_keyframes_command( input )
    
    with open( keyframes_list_file, "wb" ) as f:
        exec_cmd( cmd, f )
    
    with open( keyframes_list_file ) as f:
        
        lines = f.read().splitlines()
        keyframes = [ float( line ) for line in lines ]

    # remove temporary file with keyframes list
    #os.remove( keyframes_list_file )

    keyframes.sort()
    return keyframes
