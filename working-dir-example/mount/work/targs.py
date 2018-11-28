targs = {
    "video": {
        # copy video codec cannot be used with scaling
        "codec": 'libx264',
        "bitrate": '2459k'
    },
    "audio": {
        "codec": 'copy',
        #"bitrate": '128k'
    },
    #"use_frame_rate": False,
    "frame_rate": '25',

    # resolution must be treated as string
    # "resolution": ['1280', '720'],

    # can access width, height as below
    # "resolution": ['iw*0.9', 'ih*0.9'],

    # keep the aspect ratio, we need to specify only one component
    # and set the other component to -1
    # "resolution": ['-1', '120'],

    # Some codecs require the size of width and height to be a multiple of n.
    # You can achieve this by setting the width or height to -n:
    "resolution": ['400', '400'],

    # https://ffmpeg.org/ffmpeg-scaler.html
    "scaling_alg": 'bicubic',
}
