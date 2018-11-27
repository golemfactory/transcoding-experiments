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
def split_video_command( input, output_list_file, segment_time ):

    cmd = [ FFMPEG_COMMAND,
        "-i", input,
        "-hls_time", "{}".format( segment_time ),
        "-hls_list_size", "0",
        "-c", "copy",
        "-copyts",
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
def merge_videos_command( input_file, output ):

    cmd = [ FFMPEG_COMMAND,
        "-i", input_file,
        "-copyts",
        "-c", "copy", output
    ]

    return cmd, input_file

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
def split_video( input, output_list_file, segment_time ):

    cmd, file_list = split_video_command( input, output_list_file, segment_time )
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
    os.remove( keyframes_list_file )

    keyframes.sort()
    return keyframes


######################################
##
def prepare_transcode_command(track, output_playlist_name, targs):
    cmd = [FFMPEG_COMMAND,
           # process an input file
           "-i",
           # input file
           "{}".format(track),
           # It states that all entries from list should be processed, default is 5
           "-hls_list_size", "0",
           "-copyts"
           # "-nostdin",
           # "-reset_timestamps", "1",
           ]

    # video settings
    try:
        codec = targs['video']['codec']
        cmd.append("-c:v")
        cmd.append(codec)
    except:
        pass
    try:
        fps = targs['frame_rate']
        cmd.append("-r")
        cmd.append(fps)
    except:
        pass
    try:
        vbitrate = targs['video']['bitrate']
        cmd.append("-b:v")
        cmd.append(vbitrate)
    except:
        pass
    # audio settings
    try:
        acodec = targs['audio']['codec']
        cmd.append("-c:a")
        cmd.append(acodec)
    except:
        pass
    try:
        abitrate = targs['audio']['bitrate']
        cmd.append("-c:a")
        cmd.append(abitrate)
    except:
        pass
    try:
        res = targs['resolution']
        cmd.append("-vf")
        cmd.append("scale={}:{}".format(res[0], res[1]))
    except:
        pass
    try:
        scale = targs["scaling_alg"]
        cmd.append("-sws_flags")
        cmd.append("{}".format(scale))
    except:
        pass

    cmd.append("{}".format(output_playlist_name))

    return cmd


######################################
##
def transcode_video(track, output_playlist_name, targs):
    cmd = prepare_transcode_command(track, output_playlist_name, targs)
    return exec_cmd(cmd)
