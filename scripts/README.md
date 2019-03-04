## Miscellaneous scripts for experimenting with video splitting and merging

### split-transcode-merge-with-ffmpeg-segment.sh
Usage:
```
./split-transcode-merge-with-ffmpeg-segment.sh <input_file> <output_dir> <num_segments>
```

Uses `ffmpeg` to split `input_file` into `num_segment` fragments of approximately equal duration, resize each one separately and then merge them back into a single video.
For comparison also does the same transformation without splitting and merging.
Leaves results in the `output_dir` directory.

### show-frame-types.sh
Usage:
```
./show-frame-types.sh <input_file>
```

Uses `ffprobe -show_frames` to get a list of frame types in the video and prints them all as a sequence.
Also prints counts for each type.

### show-ssim-and-psnr.sh
``` bash
./show-ssim-and-psnr.sh <video_file1> <video_file2>
```

Uses `ffmpeg` to calculate SSIM and PSNR between all the frame pairs in to video files.

### visual-video-diff.sh
``` bash
./visual-video-diff.sh <video_file1> <video_file2>
```

Uses `ffplay` to play a video showing the difference between two video files.

### Examples
``` bash
./split-transcode-merge-with-ffmpeg-segment.sh Beach.mp4 beach-split 12
./show-frame-types.sh beach-split/Beach-merged-transcoded.mp4
./show-frame-types.sh beach-split/Beach-transcoded.mp4
./show-ssim-and-psnr.sh beach-split/Beach-merged-transcoded.mp4 beach-split/Beach-transcoded.mp4
```
