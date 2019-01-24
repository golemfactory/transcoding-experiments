import os


def build_new_name(filepath, target_codec):

    name = os.path.basename( filepath )
    [ base, rest_with_ext ] = name.split("[")
    [ _, ext ] = rest_with_ext.split(".")

    return base + "-[codec=" + target_codec + "]" + ext


def codec_to_encoder_name(target_codec):

    encoders = dict()
    encoders[ "h264" ] = "libx264"

    return encoders[ target_codec ]


def create_codec_change_params(filepath, target_codec, parts):

    params = dict()
    params[ "host_stream_path" ] = filepath
    params[ "path_to_stream" ] = os.path.join( "/golem/resources/", os.path.basename( filepath ) )
    params[ "parts" ] = parts
    params[ "output_stream" ] = os.path.join( "/golem/output/", build_new_name( filepath, target_codec ) )
    params[ "targs" ] = dict()
    
    params[ "targs" ][ "audio" ] = dict()
    params[ "targs" ][ "audio" ][ "codec" ] = "copy"

    params[ "targs" ][ "video" ] = dict()
    params[ "targs" ][ "video" ][ "codec" ] = codec_to_encoder_name(target_codec)

    return params


def get_default_test_dir():
    return os.path.join( os.getcwd(), "working-dir/test/" )


def build_test_directory_path(filepath, test_purpose):
    
    test_dir = get_default_test_dir()
    [ test_name, _ ] = os.path.splitext( os.path.basename( filepath ) )

    return os.path.join( test_dir, test_purpose, test_name)
