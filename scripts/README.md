## Miscellaneous scripts for experimenting with video splitting and merging

### split-transcode-merge-with-ffmpeg-segment.sh
Usage:
```
./split-transcode-merge-with-ffmpeg-segment.sh <input_file> <output_dir> <num_segments>
```

Uses `ffmpeg` to split `input_file` into `num_segment` fragments of approximately equal duration, resize each one separately and then merge them back into a single video.
For comparison also does the same transformation without splitting and merging.
Leaves results in the `output_dir` directory.

### Examples
``` bash
./split-transcode-merge-with-ffmpeg-segment.sh Beach.mp4 beach-split 12
```
