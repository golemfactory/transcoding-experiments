import sys
sys.path.append("ffmpeg-scripts/")

import pytest

import ffmpeg_commands as ffmpeg



@pytest.mark.parametrize("videofile,expected_length", [
    ("tests/videos/different-codecs/big-buck-bunny-[codec=theora].ogv", 60.708333),
    ("tests/videos/different-codecs/big-bunny-[codec=flv1].flv", 54.082),
    ("tests/videos/different-codecs/carphone_qcif-[codec=rawvideo].y4m", 12.746067),
    ("tests/videos/different-codecs/Dance-[codec=mpeg2video].mpeg", 30.166667),
    ("tests/videos/different-codecs/ForBiggerBlazes-[codec=h264].mp4", 14.995000),
    ("tests/videos/different-codecs/ForBiggerMeltdowns-[codec=mpeg4].mp4", 15.020833),
    ("tests/videos/different-codecs/Panasonic-[codec=vp9].webm", 46.12),
    ("tests/videos/different-codecs/star_trails-[codec=wmv2].wmv", 21.2490),
    ("tests/videos/different-codecs/TRA3106-[codec=h263].3gp", 16.9840)
])
def test_get_video_len(videofile, expected_length):
    assert(ffmpeg.get_video_len(videofile) == expected_length)

