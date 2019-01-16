import os
import glob
import json
import shutil

import docker_utils as docker
import extract_params


PARAMS_TMP="working-dir/tmp/work/params.json"
SCRIPT="working-dir-example/mount/work/task.py"



def load_params(file):
    with open(file, 'r') as f:
        params = json.load(f)
    return params


def save_params(params, output):

    dirname = os.path.dirname(output)
    if not os.path.exists(dirname):
        os.makedirs(dirname)

    with open(output, 'w+') as f:
        json.dump(params, f)


def create_save_split_params(task_def, params_dir):
    
    params = dict( task_def )
    params[ "command" ] = "split"
    del params[ "host_stream_path" ]        # Task definition for docker doesn't have this field.

    save_params( params, params_dir )


def create_save_merge_params(task_def, params_dir):

    params = dict( task_def )
    params[ "command" ] = "merge"
    params[ "use_playlist" ] = 0
    del params[ "host_stream_path" ]        # Task definition for docker doesn't have this field.

    save_params( params, params_dir )


def create_save_transcode_params(task_def, params_dir, track):

    params = dict( task_def )
    params[ "command" ] = "transcode"
    params[ "use_playlist" ] = 1
    params[ "track" ] = track
    del params[ "host_stream_path" ]        # Task definition for docker doesn't have this field.
    
    save_params( params, params_dir )


def transcoding_dir( tests_dir, subtask_num ):
    return os.path.join( tests_dir, "transcode/" + str( subtask_num ) )


def splitting_dir( tests_dir ):
    return os.path.join( tests_dir, "split" )

def merging_dir( tests_dir ):
    return os.path.join( tests_dir, "merge" )


def clean_step(tests_dir):
    if os.path.exists( tests_dir ):
        shutil.rmtree(tests_dir)


def split_video(task_def, tests_dir, image):

    print("Splitting...")

    tests_dir = os.path.join( tests_dir, "split" )

    # Create split command
    create_save_split_params( task_def, PARAMS_TMP )

    # Prepare files that should be copied to docker environment (mounted directories).
    work_files = [
        SCRIPT,
        PARAMS_TMP
    ]

    resource_files = [
        task_def[ "host_stream_path" ],
    ]

    # These commands will prepare environment for docker to run.
    # work_files and resource_files will be copied to work and resources directory.
    mounts = docker.default_golem_mounts( tests_dir )
    docker.create_environment( tests_dir, mounts, work_files, resource_files )

    # Run docker
    docker.run(image, "task.py", mounts)


def transcoding_step(task_def, tests_dir, image):

    print("Transcoding...")

    # List files with merge lists.
    m3u8_list = glob.glob( os.path.join( splitting_dir( tests_dir ), "output/" ) + "*].m3u8")

    [ basename, _ ] = os.path.splitext( os.path.basename( task_def[ "path_to_stream" ] ) )

    for m3u8_file in m3u8_list:

        subtask_num = extract_params.extract_params( m3u8_file )[ "num" ]
        subtask_dir = transcoding_dir( tests_dir, subtask_num )
        video_part_file = os.path.join( os.path.dirname(m3u8_file), basename + "_" + str(subtask_num) + ".ts" )

        # Update params for this subtask
        track = os.path.join( "/golem/resources/", os.path.basename( m3u8_file ) )
        create_save_transcode_params(task_def, PARAMS_TMP, track)

        # Prepare files that should be copied to docker environment (mounted directories).
        work_files = [
            SCRIPT,
            PARAMS_TMP
        ]

        resource_files = [
            m3u8_file,
            video_part_file
        ]

        # These commands will prepare environment for docker to run.
        # work_files and resource_files will be copied to work and resources directory.
        mounts = docker.default_golem_mounts( subtask_dir )
        docker.create_environment( subtask_dir, mounts, work_files, resource_files )

        # Run docker
        docker.run(image, "task.py", mounts)


def collect_results(task_def, tests_dir):

    results = []

    num_subtasks = task_def[ "parts" ]
    for part in range( 0, num_subtasks ):
        subtask_dir = os.path.join( transcoding_dir( tests_dir, part ), "output" )
        results += [ os.path.join( subtask_dir, file ) for file in  os.listdir( subtask_dir ) ]

    return results


def merging_step(task_def, tests_dir, image):

    print("Merging...")

    # Create metge command
    create_save_merge_params(task_def, PARAMS_TMP)

    # Prepare files that should be copied to docker environment (mounted directories).
    work_files = [
        SCRIPT,
        PARAMS_TMP
    ]

    resource_files = collect_results(task_def, tests_dir)

    # These commands will prepare environment for docker to run.
    # work_files and resource_files will be copied to work and resources directory.
    mounts = docker.default_golem_mounts( merging_dir( tests_dir ) )
    docker.create_environment( merging_dir( tests_dir ), mounts, work_files, resource_files )

    # Run docker
    docker.run(image, "task.py", mounts)


def run_pipeline(task_def, tests_dir, image):

    clean_step(tests_dir)
    split_video(task_def, tests_dir, image)
    transcoding_step(task_def, tests_dir, image)
    merging_step(task_def, tests_dir, image)


def run():

    PARAMS="working-dir/mount/work/params.json"

    task_def = load_params(PARAMS)
    tests_dir = os.path.join( os.getcwd(), "working-dir/test/" )

    run_pipeline(task_def, tests_dir, "golemfactory/ffmpeg:0.2")


if __name__ == "__main__":
    run()


