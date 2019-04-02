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
