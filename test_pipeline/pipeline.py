import os
import glob
import json
import shutil

import docker_utils as docker
from extract_params import extract_params

import compare_video

PARAMS_TMP = "working-dir/tmp/work/params.json"

SPLIT_LOG = "split.log"
MERGE_LOG = "merge.log"
TRANSCODING_LOG = "transcoding.log"
METRICS_LOG = "metrics-generation.log"

import time

time_meassurments = dict()


def start_meassure_time(name):
    global time_meassurments

    start_time = time.time()
    time_meassurments[name] = start_time


def end_meassure_time(name):
    global time_meassurments

    start_time = time_meassurments[name]
    end_time = time.time()

    time_meassurments[name] = end_time - start_time


def print_meassurments():
    print("==================================================================")
    print("Transcoding performance:")
    for name, time in time_meassurments.items():
        print( "{0: <40} {1}".format( name, time ) )

    print("==================================================================")


def split_log_file(tests_dir):
    return os.path.join(tests_dir, SPLIT_LOG)


def merge_log_file(tests_dir):
    return os.path.join(tests_dir, MERGE_LOG)


def transcoding_log_file(tests_dir, subtask_num):
    return os.path.join(transcoding_dir(tests_dir, subtask_num), TRANSCODING_LOG)


def metrics_log_file(tests_dir):
    return os.path.join(tests_dir, METRICS_LOG)


def load_params(file):
    with open(file, 'r') as f:
        params = json.load(f)
    return params


def save_params(params, output):
    dirname = os.path.dirname(output)
    if not os.path.exists(dirname):
        os.makedirs(dirname)

    with open(output, 'w+') as f:
        json.dump(params, f)


def create_save_split_params(task_def, params_dir):
    params = dict()
    params["command"] = "split"
    params["path_to_stream"] = task_def["path_to_stream"]
    params["parts"] = task_def["parts"]

    save_params(params, params_dir)


def create_save_merge_params(task_def, params_dir):
    params = dict()
    params["command"] = "merge"
    params["use_playlist"] = 0
    params["output_stream"] = task_def["output_stream"]

    save_params(params, params_dir)


def create_save_transcode_params(task_def, params_dir, track, use_playlist=True):
    params = dict()
    params["command"] = "transcode"

    if use_playlist:
        params["use_playlist"] = 1
    else:
        params["use_playlist"] = 0

    params["track"] = track
    params["output_stream"] = task_def["output_stream"]
    params["targs"] = dict(task_def["targs"])

    save_params(params, params_dir)


def transcoding_dir(tests_dir, subtask_num):
    if isinstance(subtask_num, str):
        return os.path.join(tests_dir, "transcode/" + subtask_num)
    else:
        return os.path.join(tests_dir, "transcode/" + str(subtask_num))


def splitting_dir(tests_dir):
    return os.path.join(tests_dir, "split")


def merging_dir(tests_dir):
    return os.path.join(tests_dir, "merge")


def metrics_dir(tests_dir):
    return os.path.join(tests_dir, "metrics")


def clean_step(tests_dir):
    if os.path.exists(tests_dir):
        shutil.rmtree(tests_dir)


def check_if_output_files_exist(test_dir, files_list):
    out_dir = os.path.join(test_dir, "output")
    for file in files_list:
        path = os.path.join(out_dir, file)
        assert (os.path.exists(path))


def run_ffmpeg_task(image, task_dir, work_files, resource_files, docker_log):
    # These commands will prepare environment for docker to run.
    # work_files and resource_files will be copied to work and resources directory.
    mounts = docker.default_golem_mounts(task_dir)
    docker.create_environment(task_dir, mounts, work_files, resource_files)

    # Run docker
    docker.run(image, "/golem/scripts/ffmpeg_task.py", mounts, docker_log)


def split_video(task_def, tests_dir, image):
    print("==================================================================")
    print("Splitting...")

    start_meassure_time("Splitting")

    tests_dir = os.path.join(tests_dir, "split")

    # Create split command
    create_save_split_params(task_def, PARAMS_TMP)

    # Prepare files that should be copied to docker environment (mounted directories).
    work_files = [
        PARAMS_TMP
    ]

    resource_files = [
        task_def["host_stream_path"],
    ]

    run_ffmpeg_task(image, tests_dir, work_files, resource_files, split_log_file(tests_dir))

    end_meassure_time("Splitting")


def transcoding_step(task_def, tests_dir, image):
    print("==================================================================")
    print("Transcoding...")

    start_meassure_time("Transcoding")

    subtasks_file = os.path.join(splitting_dir(tests_dir), "output/split-results.json")
    subtasks = load_params(subtasks_file)

    for segment in subtasks["segments"]:
        subtask_num = extract_params(segment["playlist"])["num"]
        subtask_dir = transcoding_dir(tests_dir, subtask_num)

        # Update params for this subtask
        track = os.path.join("/golem/resources/", os.path.basename(segment["playlist"]))
        create_save_transcode_params(task_def, PARAMS_TMP, track)

        # Prepare files that should be copied to docker environment (mounted directories).
        work_files = [
            PARAMS_TMP
        ]

        splited_files_dir = os.path.join(splitting_dir(tests_dir), "output/")

        resource_files = [
            os.path.join(splited_files_dir, segment["playlist"]),
            os.path.join(splited_files_dir, segment["video_segment"])
        ]

        run_ffmpeg_task(image, subtask_dir, work_files, resource_files, transcoding_log_file(tests_dir, subtask_num))

    end_meassure_time("Transcoding")


def collect_results(task_def, tests_dir):
    results = []

    num_subtasks = task_def["parts"]
    for part in range(0, num_subtasks):
        subtask_dir = os.path.join(transcoding_dir(tests_dir, part), "output")
        results += [os.path.join(subtask_dir, file) for file in os.listdir(subtask_dir)]

    return results


def merging_step(task_def, tests_dir, image):
    print("==================================================================")
    print("Merging...")

    start_meassure_time("Merging")

    # Create metge command
    create_save_merge_params(task_def, PARAMS_TMP)

    # Prepare files that should be copied to docker environment (mounted directories).
    work_files = [
        PARAMS_TMP
    ]

    resource_files = collect_results(task_def, tests_dir)

    run_ffmpeg_task(image, merging_dir(tests_dir), work_files, resource_files, merge_log_file(merging_dir(tests_dir)))

    check_if_output_files_exist(merging_dir(tests_dir), [os.path.basename(task_def["output_stream"])])

    end_meassure_time("Merging")


def transcode_reference(task_def, tests_dir, image):
    print("==================================================================")
    print("Transcoding reference video...")

    start_meassure_time("Reference")

    # Update params for this subtask
    track = os.path.join("/golem/resources/", os.path.basename(task_def["path_to_stream"]))
    create_save_transcode_params(task_def, PARAMS_TMP, track, False)

    subtask_dir = transcoding_dir(tests_dir, "reference")

    # Prepare files that should be copied to docker environment (mounted directories).
    work_files = [
        PARAMS_TMP
    ]

    resource_files = [
        task_def["host_stream_path"]
    ]

    run_ffmpeg_task(image, subtask_dir, work_files, resource_files, transcoding_log_file(tests_dir, "reference"))

    end_meassure_time("Reference")


def compute_metrics(task_def, tests_dir, image):
    print("==================================================================")
    print("Computing metrics...")

    start_meassure_time("Metrics")

    reference_out_name = os.path.basename(task_def["path_to_stream"])
    [name, ext] = os.path.splitext(reference_out_name)
    reference_out_name = name + "_TC" + ext

    video_path = os.path.join(merging_dir(tests_dir), "output", os.path.basename(task_def["output_stream"]))
    reference_path = os.path.join(transcoding_dir(tests_dir, "reference"), "output", reference_out_name)

    new_reference_path = reference_path
    # new_reference_path = os.path.join( os.path.dirname( reference_path ), "reference-" + os.path.basename( reference_path ) )
    # shutil.move(reference_path, new_reference_path)

    params = dict()
    params["command"] = "compute-metrics"
    params["metrics_params"] = dict()

    params["metrics_params"]["ssim"] = dict()
    ssim_params = params["metrics_params"]["ssim"]
    ssim_params["video"] = os.path.basename(video_path)
    ssim_params["reference"] = os.path.basename(new_reference_path)
    ssim_params["output"] = "ssim_output.txt"
    ssim_params["log"] = "ssim_log.txt"

    params["metrics_params"]["psnr"] = dict()
    psnr_params = params["metrics_params"]["psnr"]
    psnr_params["video"] = os.path.basename(video_path)
    psnr_params["reference"] = os.path.basename(new_reference_path)
    psnr_params["output"] = "psnr_output.txt"
    psnr_params["log"] = "psnr_log.txt"

    params["metrics_params"]["metadata"] = list()
    metadata_list = params["metrics_params"]["metadata"]

    single_metadata = dict()
    single_metadata["video"] = os.path.basename(video_path)
    single_metadata["output"] = "video_metadata_output.txt"

    metadata_list.append(single_metadata)

    single_metadata = dict()
    single_metadata["video"] = os.path.basename(new_reference_path)
    single_metadata["output"] = "reference_metadata_output.txt"

    metadata_list.append(single_metadata)

    save_params(params, PARAMS_TMP)

    # Prepare files that should be copied to docker environment (mounted directories).
    work_files = [
        PARAMS_TMP
    ]

    resource_files = [
        video_path,
        new_reference_path
    ]

    run_ffmpeg_task(image, metrics_dir(tests_dir), work_files, resource_files, metrics_log_file(metrics_dir(tests_dir)))

    check_if_output_files_exist(metrics_dir(tests_dir), [
        "video_metadata_output.txt",
        "reference_metadata_output.txt",
        "ssim_output.txt",
        "ssim_log.txt",
        "psnr_output.txt",
        "psnr_log.txt"
    ])

    end_meassure_time("Metrics")


def compare_step(task_def, tests_dir):
    results_dir = os.path.join(metrics_dir(tests_dir), "output")

    video_meta_path = os.path.join(results_dir, "video_metadata_output.txt")
    reference_meta_path = os.path.join(results_dir, "reference_metadata_output.txt")
    psnr_log = os.path.join(results_dir, "psnr_log.txt")
    ssim_log = os.path.join(results_dir, "ssim_log.txt")

    metrics_success = True
    metadata_success = True

    metrics_success = compare_video.compare_psnr(psnr_log) and metrics_success
    metrics_success = compare_video.compare_ssim(ssim_log) and metrics_success
    metadata_success = compare_video.compare_metadata(video_meta_path, reference_meta_path) and metadata_success

    return metrics_success, metadata_success


def run_pipeline(task_def, tests_dir, image):
    clean_step(tests_dir)
    split_video(task_def, tests_dir, image)
    transcoding_step(task_def, tests_dir, image)
    merging_step(task_def, tests_dir, image)
    transcode_reference(task_def, tests_dir, image)

    compute_metrics(task_def, tests_dir, image)
    print_meassurments()

    metrics_success, metadata_success = compare_step(task_def, tests_dir)

    assert(metadata_success)
    assert(metrics_success)


def run():
    PARAMS = "working-dir/mount/work/params.json"

    task_def = load_params(PARAMS)
    tests_dir = os.path.join(os.getcwd(), "working-dir/test/")

    run_pipeline(task_def, tests_dir, "golemfactory/ffmpeg:0.2")


if __name__ == "__main__":
    run()
