import sys
sys.path.append("test_pipeline/")

import os

import pytest
import pipeline as pipeline
import test_utils as utils


DOCKER_IMAGE = "golemfactory/ffmpeg:0.2"



def test_flv1_to_h264_video():
    
    file_to_transcode = "tests/videos/different-codecs/big-bunny-[codec=flv1].flv"

    task_def = utils.create_codec_change_params( file_to_transcode, "h264", 3 )
    tests_dir = utils.build_test_directory_path( file_to_transcode, "change-codec" )

    pipeline.run_pipeline(task_def, tests_dir, DOCKER_IMAGE)
    
    # This intentionally won't happen if tests fails. User can check content of test directory.
    pipeline.clean_step(tests_dir)

