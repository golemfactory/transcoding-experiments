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



@pytest.mark.parametrize("videofile,num_parts,bitrate", [
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 3, "500k"),
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 3, "250k"),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3, "2500k"),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 3, "200k"),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 3, "500k"),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 3, "500k"),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 3, "100k"),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 3, "200k"),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 3, "500k"),
])
def test_changing_resolution(videofile, num_parts, bitrate):
    run_test_changing_bitrate( videofile, num_parts, bitrate )

    # We should check here if bitrate is really lower then before.


