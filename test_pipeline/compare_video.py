import json
import subprocess
import sys


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


def compare_format(main_format, ref_format):
    assert len(main_format) == len(ref_format)
    for attr in main_format:
        if attr == "filename":
            continue

        if main_format[attr] != ref_format[attr]:
            print("Difference in \"format\"")
            print("Main video[{}]: {}".format(attr, str(main_format[attr])))
            print("Reference video[{}]: {}\n".format(attr, str(ref_format[attr])))


def compare_stream(main_stream, ref_stream):
    assert len(main_stream) == len(ref_stream)
    for attr in main_stream:
        if main_stream[attr] != ref_stream[attr]:
            print("Difference in \"stream[{}]\"".format(main_stream['index']))
            print("Main video[{}]: {}".format(attr, str(main_stream[attr])))
            print("Reference video[{}]: {}\n".format(attr, str(ref_stream[attr])))


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
