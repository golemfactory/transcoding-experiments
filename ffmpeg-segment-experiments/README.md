## Video split/merge experiments using ffmpeg segment method
This directory contains a set of scripts that split videos into segments, process them and merge them again using various methods, analyze the results on a set of input videos and produce a set of reports.

### Usage
``` bash
./run-experiment-set.sh <num_segments> <input_dir> <output_dir> <experiment_set>
```
- `<num_segments>` is the number of segments the videos will be split into at the split stage.
    Default: 5.
- `<input_dir>` is a directory containing the videos to be used in the experiment.
    All the files in that directory, regardless of their extension, are assumed to be videos.
    Default: `input/`.
- `<output_dir>` is a directory where the intermediate and final products of the experiments are stored.
    This includes split and merged videos, cached video metadata for the reports and lists of input files for some experiment steps.
    Each experiment in the set gets a separate subdirectory which in turns contains subdirectories named after all the input videos.
    Default: `output/`.
- `<experiment_set>` is the name of the set of experiments to be performed along with reports to be produced.
    Experiment sets are represented by the shell scripts stored in the `experiment-sets/` subdirectory.
    You can create your own sets by creating new scripts there.
    The `experiments/` directory contains shell scripts available for use as individual experiments in sets.

The reports defined in the experiment set are printed to the standard output in the Markdown format when the processing ends.
The processing and report generation are completely separate steps so that with a small modification of the experiment set script it's possible to produce a report without rerunning all the experiments as long as the output files are there.

### The 2019-03-08 report
This directory also contains the manually created report with analysis of the results of my experiments, including (but not limited to) the results from running the scripts from this directory: [ffmpeg-segment-research-report-2019-03-08.md](ffmpeg-segment-research-report-2019-03-08.md).

#### Reproducing results from the report
1. Get the input files.
    - Some files are stored in [/tests/videos/different-codecs](/tests/videos/different-codecs) in this repository.
    - Some were generated:

        ``` bash
        ./generate-number-videos.sh 250 25
        ./generate-number-videos.sh 10000 25
        ```
        - Note: Some of the 250-frame files with not enough I-frames were replaced with the 10000-frame equivalents.
        - Note: Some of the files did not pass the split/merge operation successfully and were manually removed from the input set.
          Details are in the report.
    - Some files are not publicly available.
        Ask other team members about them.
2. Run the experiment sets
    - `ffmpeg -f segment` split with various transcoding options:
        ``` bash
        ./run-experiment-set.sh 5 input output ffmpeg-segment-2019-03-08
        ```
    - `ffmpeg -ss` split and concat protocol merge with various transcoding options:
        ``` bash
        ./run-experiment-set.sh 5 input output ffmpeg-ss-and-concat-protocol-2019-03-08
        ```
    - Note: one failure interrupts all the experiments and prevents the report from being printed so it's recommended to use smaller batches of the input files and run the experiment set separately on each one.
