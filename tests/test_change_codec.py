import sys
sys.path.append("test_pipeline/")

import os

import pytest
import pipeline as pipeline
import test_utils as utils


DOCKER_IMAGE = "golemfactory/ffmpeg:0.2"


def test_changing_codec(video, target_codec, parts):

    file_to_transcode = video

    task_def = utils.create_codec_change_params( file_to_transcode, target_codec, parts )
    tests_dir = utils.build_test_directory_path( file_to_transcode, "change-codec" )

    pipeline.run_pipeline(task_def, tests_dir, DOCKER_IMAGE)
    
    # This intentionally won't happen if tests fails. User can check content of test directory.
    pipeline.clean_step(tests_dir)  



@pytest.mark.parametrize("videofile,num_parts", [
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 3),
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 3),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 3),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 3),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 3),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 3),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 3),
])
def test_conversion_to_h264_video(videofile, num_parts):
    test_changing_codec( videofile, "h264", num_parts )

