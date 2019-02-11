import sys

sys.path.append("test_pipeline/")

import os

import pytest
import pipeline as pipeline
import test_utils as utils


def change_codec_test(video, target_codec, parts):
    file_to_transcode = video

<<<<<<< HEAD
    task_def = utils.create_codec_change_params( file_to_transcode, target_codec, parts )
    tests_dir = utils.build_test_directory_path( file_to_transcode, "change-codec/" + target_codec )
=======
    task_def = utils.create_codec_change_params(file_to_transcode, target_codec, parts)
    tests_dir = utils.build_test_directory_path(file_to_transcode, "change-codec")
>>>>>>> f0193ea4b34278351ebe35bcad07333ee296bfe5

    pipeline.run_pipeline(task_def, tests_dir, utils.DOCKER_IMAGE)

    # This intentionally won't happen if tests fails. User can check content of test directory.
    pipeline.clean_step(tests_dir)


@pytest.mark.parametrize("videofile,num_parts", [
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 3),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 3),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 3),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 3),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 3),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 3),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 3),
])
def test_conversion_to_flv1_video(videofile, num_parts):
    change_codec_test(videofile, "flv1", num_parts)


@pytest.mark.parametrize("videofile,num_parts", [
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 3),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 3),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 3),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 3),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 3),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 3),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 3),
])
def test_conversion_to_theora_video(videofile, num_parts):
    change_codec_test(videofile, "theora", num_parts)


@pytest.mark.parametrize("videofile,num_parts", [
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 3),
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 3),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 3),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 3),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 3),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 3),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 3),
])
def test_conversion_to_mpeg2video_video(videofile, num_parts):
    change_codec_test(videofile, "mpeg2video", num_parts)


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
    change_codec_test(videofile, "h264", num_parts)


@pytest.mark.parametrize("videofile,num_parts", [
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 3),
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 3),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 3),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 3),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 3),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 3),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 3),
])
def test_conversion_to_mpeg4_video(videofile, num_parts):
    change_codec_test(videofile, "mpeg4", num_parts)


@pytest.mark.parametrize("videofile,num_parts", [
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 3),
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 3),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 3),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 3),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 3),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 3),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 3),
])
def test_conversion_to_vp9_video(videofile, num_parts):
    change_codec_test(videofile, "vp9", num_parts)


@pytest.mark.parametrize("videofile,num_parts", [
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 3),
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 3),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 3),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 3),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 3),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 3),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 3),
])
def test_conversion_to_wmv2_video(videofile, num_parts):
    change_codec_test(videofile, "wmv2", num_parts)


@pytest.mark.parametrize("videofile,num_parts", [
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 3),
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 3),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 3),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 3),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 3),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 3),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 3),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 3),
])
def test_conversion_to_h263_video(videofile, num_parts):
    change_codec_test(videofile, "h263", num_parts)
