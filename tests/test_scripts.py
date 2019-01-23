import sys
sys.path.append("ffmpeg-scripts/")

import pytest

import ffmpeg_commands as ffmpeg



@pytest.mark.parametrize("videofile,expected_length", [
    ("working-dir/mount/resources/bear-1280x720.flv", 11.0),
    ("working-dir/mount/resources/bear-1280x720.mkv", 10.65),
    ("working-dir/mount/resources/bear-1280x720.mp4", 170.840)
])
def test_get_video_len(videofile, expected_length):
    assert(ffmpeg.get_video_len(videofile) == expected_length)

