import os

DOCKER_IMAGE = "golemfactory/ffmpeg:1.0"


def build_new_name(filepath, target_codec):
    name = os.path.basename(filepath)
    [base, rest_with_ext] = name.split("[")
    [_, ext] = rest_with_ext.split(".")

    return base + "[codec=" + target_codec + "]." + ext


def codec_to_encoder_name(target_codec):
    encoders = dict()
    encoders["h264"] = "libx264"
    encoders["flv1"] = "flv"
    encoders["theora"] = "libtheora"
    encoders["mpeg2video"] = "mpeg2video"
    encoders["rawvideo"] = "rawvideo"
    encoders["mpeg4"] = "mpeg4"
    encoders["vp9"] = "libvpx-vp9"
    encoders["wmv2"] = "wmv2"  # This could not work. There were no encoder in codecs list.
    encoders["h263"] = "h263"

    return encoders[target_codec]


def create_basic_params(filepath, parts):
    params = dict()
    params["host_stream_path"] = filepath
    params["path_to_stream"] = os.path.join("/golem/resources/", os.path.basename(filepath))
    params["parts"] = parts
    params["targs"] = dict()

    params["targs"]["audio"] = dict()
    params["targs"]["video"] = dict()

    return params


def create_codec_change_params(filepath, target_codec, parts):
    params = create_basic_params(filepath, parts)
    params["output_stream"] = os.path.join("/golem/output/", build_new_name(filepath, target_codec))

    params["targs"]["audio"]["codec"] = "copy"
    params["targs"]["video"]["codec"] = codec_to_encoder_name(target_codec)

    if target_codec == "h263":
        params["targs"]["resolution"] = [128, 96]

    return params


def create_resolution_change_params(filepath, parts, resolution, codec):
    params = create_basic_params(filepath, parts)
    params["output_stream"] = os.path.join("/golem/output/", os.path.basename(filepath))
    params["targs"]["resolution"] = resolution
    params["targs"]["scaling_alg"] = "bicubic"
    params["targs"]["video"]["codec"] = codec_to_encoder_name(codec)

    return params


def create_bitrate_change_params(filepath, parts, bitrate):
    params = create_basic_params(filepath, parts)
    params["output_stream"] = os.path.join("/golem/output/", os.path.basename(filepath))
    params["targs"]["video"]["bitrate"] = bitrate

    return params


def get_default_test_dir():
    return os.path.join(os.getcwd(), "working-dir/test/")


def build_test_directory_path(filepath, test_purpose):
    test_dir = get_default_test_dir()
    [test_name, _] = os.path.splitext(os.path.basename(filepath))

    return os.path.join(test_dir, test_purpose, test_name)
