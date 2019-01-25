import sys
sys.path.append("test_pipeline/")

import os

import pytest
import pipeline as pipeline
import test_utils as utils



def run_test_changing_bitrate(video, parts, bitrate):

    file_to_transcode = video

    task_def = utils.create_bitrate_change_params( file_to_transcode, parts, bitrate )
    tests_dir = utils.build_test_directory_path( file_to_transcode, "change-bitrate" )

    pipeline.run_pipeline(task_def, tests_dir, utils.DOCKER_IMAGE)
    
    # This intentionally won't happen if tests fails. User can check content of test directory.
    pipeline.clean_step(tests_dir)  






