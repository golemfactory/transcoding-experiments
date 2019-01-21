import json
import subprocess
import sys



BITRATE_TOLARANCE = 1000

ignored_fields = [
    "filename",
    "bit_rate",
    "size"
]




def exec_cmd(cmd, file=None):
    pc = subprocess.Popen(cmd, stdout=file)
    return pc.wait()


def print_psnr(filename):
    print("PSNR output:")
    with open(filename, "r") as ins:
        for line in ins:
            print("\t" + line)


def print_ssim(filename):
    print("SSIM output:")
    with open(filename, "r") as ins:
        for line in ins:
            print("\t" + line)


def read_json(filename):
    with open(filename) as json_file:
        data = json.load(json_file)
        return data


def print_different(main_stream, ref_stream, attribute, where):
    print("Difference in \"{}\"".format(where))
    print("Main video[{}]: {}".format(attribute, str(main_stream[attribute])))
    print("Reference video[{}]: {}\n".format(attribute, str(ref_stream[attribute])))


def compare_with_tolerance(main_stream, ref_stream, where):

    # Compare ignored attributes with tolerance
    if abs( int( main_stream[ "bit_rate" ] ) - int( ref_stream[ "bit_rate" ] ) ) > BITRATE_TOLARANCE:
        print_different(main_stream, ref_stream, "bit_rate", where)


def compare_format(main_format, ref_format):
    assert len(main_format) == len(ref_format)
    for attr in main_format:
        if attr in ignored_fields:
            continue

        if main_format[attr] != ref_format[attr]:
            print_different(main_format, ref_format, attr, "format")
    compare_with_tolerance(main_format, ref_format, "format")


def compare_stream(main_stream, ref_stream):
    assert len(main_stream) == len(ref_stream)
    for attr in main_stream:
        if attr in ignored_fields:
            continue

        if main_stream[attr] != ref_stream[attr]:
            print_different(main_stream, ref_stream, attr, "stream[{}]".format(main_stream['index']))

    compare_with_tolerance(main_stream, ref_stream, "stream[{}]".format(main_stream['index']))


def compare_metadata(main_json, ref_json):
    main_data = read_json(main_json)
    ref_data = read_json(ref_json)

    compare_format(main_data['format'], ref_data['format'])
    assert len(main_data['streams']) == len(ref_data['streams'])
    for i in range(0, len(main_data['streams'])):
        compare_stream(main_data['streams'][i], ref_data['streams'][i])


def run():
    psnr_log = sys.argv[1]
    ssim_log = sys.argv[2]
    main_json = sys.argv[3]
    ref_json = sys.argv[4]

    print_psnr(psnr_log)
    print_ssim(ssim_log)
    compare_metadata(main_json, ref_json)


if __name__ == "__main__":
    run()
