import os
import glob
import json
import shutil

import docker_utils as docker



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


def clean_step(tests_dir):
    shutil.rmtree(tests_dir)


def split_video(task_def, tests_dir, image):

    print("Splitting...")

    # Create split command
    params = dict( task_def )
    params[ "command" ] = "split"
    del params[ "host_stream_path" ]        # Task definition for docker doesn't have this field.

    save_params( params, PARAMS_TMP )

    # Prepare files that should be copied to docker environment (mounted directories).
    work_files = [
        SCRIPT,
        PARAMS_TMP
    ]

    resource_files = [
        task_def[ "host_stream_path" ],
    ]

    # These commands will prepare environment for docker to run.
    mounts = docker.default_golem_mounts( tests_dir )
    docker.create_environment( tests_dir, mounts, work_files, resource_files )

    # Run docker
    docker.run(image, "task.py", mounts)


def run_pipeline(task_def, tests_dir, image):

    clean_step(tests_dir)
    split_video(task_def, os.path.join( tests_dir, "split" ), image )



def run():

    PARAMS="working-dir/mount/work/params.json"

    task_def = load_params(PARAMS)
    tests_dir = os.path.join( os.getcwd(), "working-dir/test/" )

    run_pipeline(task_def, tests_dir, "golemfactory/ffmpeg:0.2")


if __name__ == "__main__":
    run()


