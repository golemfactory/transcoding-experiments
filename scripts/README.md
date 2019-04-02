## Miscellaneous scripts for experimenting with video splitting and merging

### Split/merge and analyzing the results

#### split-transcode-merge-with-ffmpeg-segment.sh
Usage:
```
./split-transcode-merge-with-ffmpeg-segment.sh <input_file> <output_dir> <num_segments>
```

Uses `ffmpeg` to split `input_file` into `num_segment` fragments of approximately equal duration, resize each one separately and then merge them back into a single video.
For comparison also does the same transformation without splitting and merging.
Leaves results in the `output_dir` directory.

#### show-frame-types.sh
Usage:
```
./show-frame-types.sh <input_file>
```

Uses `ffprobe -show_frames` to get a list of frame types in the video and prints them all as a sequence.
Also prints counts for each type.

#### show-ssim-and-psnr.sh
``` bash
./show-ssim-and-psnr.sh <video_file1> <video_file2>
```

Uses `ffmpeg` to calculate SSIM and PSNR between all the frame pairs in to video files.

#### visual-video-diff.sh
``` bash
./visual-video-diff.sh <video_file1> <video_file2>
```

Uses `ffplay` to play a video showing the difference between two video files.

#### dump-frame-diff.sh
``` bash
./dump-frame-diff.sh <reference_file> <new_file> <output_dir> <duration>
```

Accepts two files as arguments: the reference file we're comparing to and a new file that might differ from it.
The script extracts individual frames from both videos into two sequences of PNG images.
Then it also uses `ffmpeg` to compute the difference between the frames in the two videos and extract those differences as another PNG sequence.

The output is stored in subdirectories of `<output_dir>`.
Since the full PNG images are big and there are a lot of them, the `<duration>` argument specifies the duration (in seconds) of the initial part of the video that should be processed.

#### frame-mosaic-diff.sh
``` bash
./frame-mosaic-diff.sh <reference_file> <new_file> <output_dir>
```

Works similarly to `dump-frame-diff.sh` but instead of dumping full images, it only creates small thumbnails.
Then it uses ImageMagick to create big PNG images composed of all the thumbnails - one for the reference file, one for the new file and one for the diff.
The mosaics (especially the one made of diff frames) show at a glance whether the videos are completely different or almost identical.

#### Examples
``` bash
./split-transcode-merge-with-ffmpeg-segment.sh Beach.mp4 beach-split 12
./show-frame-types.sh beach-split/Beach-transcoded.mp4
./show-frame-types.sh beach-split/Beach-merged-transcoded.mp4
./show-ssim-and-psnr.sh beach-split/Beach-transcoded.mp4 beach-split/Beach-merged-transcoded.mp4
./visual-video-diff.sh beach-split/Beach-transcoded.mp4 beach-split/Beach-merged-transcoded.mp4
./dump-frame-diff.sh beach-split/Beach-transcoded.mp4 beach-split/Beach-merged-transcoded.mp4 beach-split/diff 10
./frame-mosaic-diff.sh beach-split/Beach-transcoded.mp4 beach-split/Beach-merged-transcoded.mp4 beach-split/mosaic
```

### Transcoding benchmark

#### ffmpeg-transcoding-benchmark.sh
``` bash
./ffmpeg-transcoding-benchmark.sh <input_file> <output_dir>
```

Uses ffmpeg to transcode specified file to a series of different codecs, measures the time of each operation and and prints a short report.

The slowest codecs are tested last - some of them (most notably AV1) take a very long time even for very small files.

The selection of codecs is quite arbitrary but includes the most popular ones.
Different sets of codecs can be tested by modifying the list in the script.

`<output_dir>` is used to store the transcoded files so that they can be inspected.

#### Examples

``` bash
./ffmpeg-transcoding-benchmark.sh Beach.mp4 /tmp/output
```

### Generating syntnetic videos using various codecs and containters
#### generate-number-videos.sh
Usage:
```
./generate-number-videos.sh <num_frames> <gop_size>
```

Uses ImageMagick to generate a PNG image sequence consisting of `<num_frames>` images with subsequent numbers, starting at 1.
Then uses the images as input for `ffmpeg` to generate 25 FPS videos without audio track.

`<gop_size>` is the size of a single [Group of Pictues](https://en.wikipedia.org/wiki/Group_of_pictures) in the resulting video.
A GOP always starts with an I-frame so setting a lower value ensures that there are enough I-frames to make splitting a video into more segments possible without transcoding.
The default value is 25.
Note that not all codecs respect this value.

The set of codecs and containers is hard-coded in the script.
They were chosen arbitrarily, based on what `ffmpeg -codecs` and `ffmpeg -formats` report, but with emphasis on more popular combinations, with some less popular ones sprinkled in.

The script leaves numbered frames in `number-frames/` and videos in `number-videos/`.

#### Examples
``` bash
./generate-number-videos.sh 10000 25
```
