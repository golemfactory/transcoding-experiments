# `ffmpeg -segment` research report 2019-03-08
Table of contents:

1. [ffmpeg version](#1-ffmpeg-version)
2. [Test videos used in experiments](#2-test-videos-used-in-experiments)
    1. [Codecs used in test videos](#codecs-used-in-test-videos)
    2. [Columns](#columns)
    3. [Generated videos with numbered frames](#generated-videos-with-numbered-frames)
    4. [Videos from the `transcoding_experiments` repository](#videos-from-the-transcoding_experiments-repository)
    5. [Problematic videos provided by the CGI team](#problematic-videos-provided-by-the-cgi-team)
    6. [Miscellaneous videos](#miscellaneous-videos)
    7. [Observations](#observations)
3. [Split&merge reports for tested files](#3-splitmerge-reports-for-tested-files)
    1. [Tested methods](#tested-methods)
    2. [Video duration and start time reports](#video-duration-and-start-time-reports)
    3. [Frame type reports](#frame-type-reports)
    4. [Anomalies observed in results](#anomalies-observed-in-results)
4. [Analysis of bad files](#4-analysis-of-bad-files)
    1. [Overview of observed problems](#overview-of-observed-problems)
    2. [Generated videos with numbered frames](#generated-videos-with-numbered-frames-1)
    3. [Videos from the `transcoding_experiments` repository](#videos-from-the-transcoding_experiments-repository-1)
5. [Frame types in the test videos](#5-frame-types-in-the-test-videos)
    1. [Frame types in the shorter videos](#frame-types-in-the-shorter-videos)
    2. [Frame type changes during split, transcoding and merge](#frame-type-changes-during-split-transcoding-and-merge)
    3. [Observations](#observations-1)
6. [`duration` and `start_time` changes when splitting and merging `gada.mp4`](#6-duration-and-start_time-changes-when-splitting-and-merging-gadamp4)
    1. [Gathered information](#gathered-information)
    2. [Conclusions](#conclusions)
7. [Reproducing split&merge artifacts observed by the CGI team](#7-reproducing-splitmerge-artifacts-observed-by-the-cgi-team)
    1. [Experiment setup](#experiment-setup)
    2. [Methods tested](#methods-tested)
    3. [Gathered information](#gathered-information-1)
    4. [Conclusions](#conclusions-1)
8. [Frame shift in merged `gada.mp4`](#8-frame-shift-in-merged-gadamp4)
    1. [Input](#input)
    2. [Observations](#observations-2)
    3. [Looking closer at the segments](#looking-closer-at-the-segments)
    4. [Experiments: effects of extra processing on the frame shift](#experiments-effects-of-extra-processing-on-the-frame-shift)
    5. [Conclusions](#conclusions-2)

All the experiments in this report were splitting the file into 5 segments unless stated otherwise.
Note that this does no mean that that was the actual number of segments - for example ffmpeg segment chooses split points on its own, using desired segment duration only as a hint.

## 1. ffmpeg version
```
ffmpeg version n4.1.1 Copyright (c) 2000-2019 the FFmpeg developers
  built with gcc 8.2.1 (GCC) 20181127
  configuration: --prefix=/usr --disable-debug --disable-static --disable-stripping --enable-fontconfig --enable-gmp --enable-gnutls --enable-gpl --enable-ladspa --enable-libaom --enable-libass --enable-libbluray --enable-libdrm --enable-libfreetype --enable-libfribidi --enable-libgsm --enable-libiec61883 --enable-libjack --enable-libmodplug --enable-libmp3lame --enable-libopencore_amrnb --enable-libopencore_amrwb --enable-libopenjpeg --enable-libopus --enable-libpulse --enable-libsoxr --enable-libspeex --enable-libssh --enable-libtheora --enable-libv4l2 --enable-libvidstab --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libx264 --enable-libx265 --enable-libxcb --enable-libxml2 --enable-libxvid --enable-nvdec --enable-nvenc --enable-omx --enable-shared --enable-version3
  libavutil      56. 22.100 / 56. 22.100
  libavcodec     58. 35.100 / 58. 35.100
  libavformat    58. 20.100 / 58. 20.100
  libavdevice    58.  5.100 / 58.  5.100
  libavfilter     7. 40.101 /  7. 40.101
  libswscale      5.  3.100 /  5.  3.100
  libswresample   3.  3.100 /  3.  3.100
  libpostproc    55.  3.100 / 55.  3.100
```

## 2. Test videos used in experiments
"good" files are the ones that were usable in experiments described in later sections of this document.
This does not necessarily mean that the result of split and merge in these experiments was correct.
"bad" files are the ones that caused severe ffmpeg errors and it was not possible to gather sensible data for them.
They might be usable with some extra options or preprocessing but it was not investigated yet.

### Codecs used in test videos
| ffmpeg codec tag | Description                                                  |
|------------------|--------------------------------------------------------------|
| av1              | Alliance for Open Media AV1                                  |
| cinepak          | Cinepak                                                      |
| dirac            | Dirac                                                        |
| flv1             | FLV / Sorenson Spark / Sorenson H.263 (Flash Video)          |
| h261             | H.261                                                        |
| h263             | H.263 / H.263-1996, H.263+ / H.263-1998 / H.263 version 2    |
| h263p            | H.263+ / H.263-1998 / H.263 version 2                        |
| h264             | H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10                    |
| hevc             | H.265 / HEVC (High Efficiency Video Coding)                  |
| mjpeg            | Motion JPEG                                                  |
| mpeg1video       | MPEG-1 video                                                 |
| mpeg2video       | MPEG-2 video                                                 |
| mpeg4            | MPEG-4 part 2                                                |
| theora           | Theora                                                       |
| vp8              | On2 VP8                                                      |
| vp9              | Google VP9                                                   |
| wmv1             | Windows Media Video 7                                        |
| wmv2             | Windows Media Video 8                                        |
| huffyuv          | HuffYUV                                                      |
| msmpeg4v2        | MPEG-4 part 2 Microsoft variant version 2                    |
| msmpeg4v3        | MPEG-4 part 2 Microsoft variant version 3                    |
| svq1             | Sorenson Vector Quantizer 1 / Sorenson Video 1 / SVQ1        |
| v210             | Uncompressed 4:2:2 10-bit                                    |
| v308             | Uncompressed packed 4:4:4                                    |
| v408             | Uncompressed packed QT 4:4:4:4                               |
| v410             | Uncompressed 4:4:4 10-bit                                    |
| y41p             | Uncompressed YUV 4:1:1 12-bit                                |
| yuv4             | Uncompressed packed 4:2:0                                    |
| rv10             | RealVideo 1.0                                                |
| rv20             | RealVideo 2.0                                                |
| rawvideo         | raw video                                                    |
| dvvideo          | DV (Digital Video)                                           |

### Columns
| column         | description                                                                             |
|----------------|-----------------------------------------------------------------------------------------|
| `video`        | Name of the video file                                                                  |
| `streams`      | Total number of streams in the video file                                               |
| `format`       | Container format (from `ffprobe -show_entries format=format_name`).                     |
| `codec`        | Codec used for the first video stream (from `ffprobe -show_entries stream=codec_name`). |
| `~in duration` | Duration of the video file, in seconds, rounded to the nearest integer.                 |
| `in#`          | Total number of frames in the video file.                                               |
| `in type`      | Frame types present in the file.                                                        |
| `#I in`        | Number of I-frames in the file.                                                         |
| `#P in`        | Number of P-frames in the file.                                                         |
| `#B in`        | Number of B-frames in the file.                                                         |

### Generated videos with numbered frames
- Each file contains 250 frames with numbers from 1 to 250.
    - In two cases cases longer files were generated (10000 frames) to ensure that there were multiple I-frames.
- Files were generated by producing a sequence of images with ImageMagick and converting them to a video with the codec and format specified in the name (see `generate-number-videos.sh` script).

#### Good files
| video                                  | streams | format                  | codec      | ~in duration | in#   | in type | #I in  | #P in  | #B in  |
|----------------------------------------|---------|-------------------------|------------|--------------|-------|---------|--------|--------|--------|
| numbers-10000-gop-25-hevc.mp4          |       1 | mov,mp4,m4a,3gp,3g2,mj2 | hevc       |          400 | 10000 |     BIP |     40 |   2697 |   7263 |
| numbers-10000-gop-25-hevc.mpeg         |       1 | mpeg                    | hevc       |          400 | 10000 |     BIP |     40 |   2697 |   7263 |
| numbers-250-gop-25-av1.mkv             |       1 | matroska,webm           | av1        |           10 |   250 |       ? |      0 |      0 |      0 |
| numbers-250-gop-25-cinepak.cpk         |       1 | film_cpk                | cinepak    |           10 |   250 |       ? |      0 |      0 |      0 |
| numbers-250-gop-25-dirac.avi           |       1 | avi                     | dirac      |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-dirac.mkv           |       1 | matroska,webm           | dirac      |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-dirac.mp4           |       1 | mov,mp4,m4a,3gp,3g2,mj2 | dirac      |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-flv1.avi            |       1 | avi                     | flv1       |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-flv1.flv            |       1 | flv                     | flv1       |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-flv1.mkv            |       1 | matroska,webm           | flv1       |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-h263.3gp            |       1 | mov,mp4,m4a,3gp,3g2,mj2 | h263       |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-h264.avi            |       1 | avi                     | h264       |           10 |   250 |     BIP |     12 |     84 |    154 |
| numbers-250-gop-25-h264.flv            |       1 | flv                     | h264       |           10 |   250 |     BIP |     12 |     84 |    154 |
| numbers-250-gop-25-h264.mkv            |       1 | matroska,webm           | h264       |           10 |   250 |     BIP |     12 |     84 |    154 |
| numbers-250-gop-25-h264.mp4            |       1 | mov,mp4,m4a,3gp,3g2,mj2 | h264       |           10 |   250 |     BIP |     12 |     84 |    154 |
| numbers-250-gop-25-huffyuv.mkv         |       1 | matroska,webm           | huffyuv    |           10 |   250 |       ? |      0 |      0 |      0 |
| numbers-250-gop-25-mjpeg.avi           |       1 | avi                     | mjpeg      |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-mjpeg.mkv           |       1 | matroska,webm           | mjpeg      |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-mjpeg.mov           |       1 | mov,mp4,m4a,3gp,3g2,mj2 | mjpeg      |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-mpeg1video.m1v      |       1 | mpegvideo               | mpeg1video |            0 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-mpeg1video.mpeg     |       1 | mpeg                    | mpeg1video |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-mpeg2video.mpeg     |       1 | mpeg                    | mpeg2video |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-mpeg4.mp4           |       1 | mov,mp4,m4a,3gp,3g2,mj2 | mpeg4      |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-mpeg4.mpeg          |       1 | mpeg                    | mpeg4      |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-msmpeg4v2.avi       |       1 | avi                     | msmpeg4v2  |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-msmpeg4v2.wmv       |       1 | asf                     | msmpeg4v2  |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-msmpeg4v3.avi       |       1 | avi                     | msmpeg4v3  |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-msmpeg4v3.wmv       |       1 | asf                     | msmpeg4v3  |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-svq1.mov            |       1 | mov,mp4,m4a,3gp,3g2,mj2 | svq1       |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-theora.mkv          |       1 | matroska,webm           | theora     |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-theora.ogv          |       1 | ogg                     | theora     |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-v210.avi            |       1 | avi                     | v210       |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-v308.avi            |       1 | avi                     | v308       |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-v408.avi            |       1 | avi                     | v408       |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-v410.avi            |       1 | avi                     | v410       |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-vp8.ivf             |       1 | ivf                     | vp8        |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-vp8.webm            |       1 | matroska,webm           | vp8        |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-vp9.avi             |       1 | avi                     | vp9        |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-vp9.webm            |       1 | matroska,webm           | vp9        |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-wmv1.asf            |       1 | asf                     | wmv1       |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-wmv2.asf            |       1 | asf                     | wmv2       |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-y41p.avi            |       1 | avi                     | y41p       |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-yuv4.avi            |       1 | avi                     | yuv4       |           10 |   250 |       I |    250 |      0 |      0 |

#### Bad files
| video                                  | streams | format                  | codec      | ~in duration | in#   | in type | #I in  | #P in  | #B in  |
|----------------------------------------|---------|-------------------------|------------|--------------|-------|---------|--------|--------|--------|
| numbers-10000-gop-25-hevc.mkv          |       1 | matroska,webm           | hevc       |          400 | 10000 |     BIP |     40 |   2697 |   7263 |
| numbers-250-gop-25-vp9.mp4             |       1 | mov,mp4,m4a,3gp,3g2,mj2 | vp9        |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-dirac.drc           |       1 | dirac                   | dirac      |          N/A |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-dvvideo.dv          |       1 | dv                      | dvvideo    |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-h261.h261           |       1 | h261                    | h261       |          N/A |   250 |       P |      0 |    250 |      0 |
| numbers-250-gop-25-h263.h263           |       1 | h263                    | h263       |          N/A |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-h263p.h263          |       1 | h263                    | h263       |          N/A |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-h264.h264           |       1 | h264                    | h264       |          N/A |   250 |     BIP |     12 |     84 |    154 |
| numbers-250-gop-25-hevc.hevc           |       1 | hevc                    | hevc       |          N/A |   250 |     BIP |      1 |     61 |    188 |
| numbers-250-gop-25-mjpeg.mjpeg         |       1 | mjpeg                   | mjpeg      |          N/A |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-msmpeg4v2.mpeg      |       1 | mpeg                    |            |           10 |     0 |         |      0 |      0 |      0 |
| numbers-250-gop-25-msmpeg4v3.mpeg      |       1 | mpeg                    |            |           10 |     0 |         |      0 |      0 |      0 |
| numbers-250-gop-25-rawvideo.mkv        |       1 | matroska,webm           | rawvideo   |           10 |   250 |       I |    250 |      0 |      0 |
| numbers-250-gop-25-rv10.rm             |       1 | rm                      | rv10       |           10 |   250 |      IP |     10 |    240 |      0 |
| numbers-250-gop-25-rv20.rm             |       1 | rm                      | rv20       |           10 |   250 |      IP |     10 |    240 |      0 |

### Videos from the `transcoding_experiments` repository
#### Good files
| video                                  | streams | format                  | codec      | ~in duration | in#   | in type | #I in  | #P in  | #B in  |
|----------------------------------------|---------|-------------------------|------------|--------------|-------|---------|--------|--------|--------|
| big-buck-bunny-[codec=theora].ogv      |       3 | ogg                     | theora     |    60.708333 |  1450 |      IP |     27 |   1423 |      0 |
| big-bunny-[codec=flv1].flv             |       2 | flv                     | flv1       |    54.082000 |  1352 |      IP |      7 |   1345 |      0 |
| ForBiggerBlazes-[codec=h264].mp4       |       2 | mov,mp4,m4a,3gp,3g2,mj2 | h264       |    15.021667 |   360 |      IP |     14 |    346 |      0 |
| ForBiggerMeltdowns-[codec=mpeg4].mp4   |       2 | mov,mp4,m4a,3gp,3g2,mj2 | h264       |    15.045000 |   361 |      IP |     12 |    349 |      0 |
| Panasonic-[codec=vp9].webm             |       2 | matroska,webm           | vp9        |    46.120000 |  1152 |      IP |      9 |   1143 |      0 |
| star_trails-[codec=wmv2].wmv           |       2 | asf                     | wmv2       |    21.292000 |   529 |      IP |     45 |    484 |      0 |
| TRA3106-[codec=h263].3gp               |       1 | mov,mp4,m4a,3gp,3g2,mj2 | h263       |    16.984000 |   509 |      IP |     53 |    456 |      0 |

#### Bad files
| video                                  | streams | format                  | codec      | ~in duration | in#   | in type | #I in  | #P in  | #B in  |
|----------------------------------------|---------|-------------------------|------------|--------------|-------|---------|--------|--------|--------|
| carphone_qcif-[codec=rawvideo].y4m     |       1 | yuv4mpegpipe            | rawvideo   |    12.746067 |   382 |       I |    382 |      0 |      0 |
| Dance-[codec=mpeg2video].mpeg          |       3 | mpeg                    | mpeg2video |    30.196733 |   362 |      IP |     31 |    331 |      0 |

### Problematic videos provided by the CGI team
#### Good files
| video                                  | streams | format                  | codec      | ~in duration | in#   | in type | #I in  | #P in  | #B in  |
|----------------------------------------|---------|-------------------------|------------|--------------|-------|---------|--------|--------|--------|
| Beach.mp4                              |       2 | mov,mp4,m4a,3gp,3g2,mj2 | h264       |    79.743333 |  1992 |     BIP |     27 |    509 |   1456 |
| byger-liten.avi                        |       1 | avi                     | mpeg4      |   121.480000 |  3037 |      IP |     49 |   2988 |      0 |
| gada.mp4                               |       2 | mov,mp4,m4a,3gp,3g2,mj2 | h264       |  1285.781767 | 32144 |     BIP |    391 |  16942 |  14811 |
| tortoise.mp4                           |       2 | mov,mp4,m4a,3gp,3g2,mj2 | h264       |   152.170000 |  4560 |     BIP |     51 |   1543 |   2966 |

### Miscellaneous videos
#### Good files
| video                                  | streams | format                  | codec      | ~in duration | in#   | in type | #I in  | #P in  | #B in  |
|----------------------------------------|---------|-------------------------|------------|--------------|-------|---------|--------|--------|--------|
| grb_2.m4v                              |       1 | mov,mp4,m4a,3gp,3g2,mj2 | h264       |    27.862000 |   835 |     BIP |      6 |    226 |    603 |
| gada-100-first-segment.mp4             |       2 | mov,mp4,m4a,3gp,3g2,mj2 | h264       |    15.360000 |   384 |     BIP |      8 |    198 |    178 |

- `gada-100-first-segment.mp4` is the first segment produced by splitting `gada.mp4` with ffmpeg segment into 100 parts.
    It can be used as a shorter sample that still has the same problems as `gada.mp4`
- [`grb_2.m4v`](http://mirrors.standaloneinstaller.com/video-sample/grb_2.m4v) is a random file downloaded from the Internet that's short but still has a sharp scene transition like `gada.mp4`.

#### Observations
- All of the problematic files contain B-frames
- All the files have multiple I-frames which should make splitting without transcoding possible.

## 3. Split&merge reports for tested files
### Tested methods
The results below have been gathered from several experiments executed for each file:
- `segment-split-only`:
    - Splitting the input file with `ffmpeg -f segment`
    - Merging the segments using ffmpeg concat demuxer (`ffmpeg -f concat`, no transcoding)
- `ss-split-only`
    - Splitting the input file by extracting every part with `ffmpeg -ss`
    - Merging the segments using ffmpeg concat demuxer (`ffmpeg -f concat`, no transcoding)
- `segment-split-half-scale`
    - Splitting the input file with `ffmpeg -f segment`
    - Transcoding to half size with `ffmpeg -vf "scale=iw*0.5:ih*0.5"`
    - Merging the transcoded segments using ffmpeg concat demuxer (`ffmpeg -f concat`)
    - Transcoding the input file in the same way without split and merge (for reference)
- `segment-split-vp9-convert`
    - Splitting the input file with `ffmpeg -f segment`
    - Transcoding to a VP9 video in a Matroska container with `ffmpeg -vcodec vp9`
    - Merging the transcoded segments using ffmpeg concat demuxer (`ffmpeg -f concat`)
    - Transcoding the input file in the same way without split and merge (for reference)
- `ss-split-half-scale`
    - Splitting the input file by extracting every part with `ffmpeg -ss`
    - Transcoding to half size with `ffmpeg -vf "scale=iw*0.5:ih*0.5"`
    - Merging the transcoded segments using ffmpeg concat demuxer (`ffmpeg -f concat`)
    - Transcoding the input file in the same way without split and merge (for reference)
- `segment-split-concat-protocol-merge-half-scale`
    - Splitting the input file with `ffmpeg -f segment`
    - Transcoding to half size with `ffmpeg -vf "scale=iw*0.5:ih*0.5"`
    - Merging the transcoded segments using ffmpeg concat protocol (`ffmpeg -i concat:a|b|c`)
    - Transcoding the input file in the same way without split and merge (for reference)

### Video duration and start time reports
#### Columns
| column         | description                                                                                                |
|----------------|------------------------------------------------------------------------------------------------------------|
| `video`        | Name of the video file used as input for the experiment.                                                   |
| `in duration`  | Duration of the input video.                                                                               |
| `out duration` | Duration of the video produced by transcoding without splitting and merging.                               |
| `mrg duration` | Duration of the video produced by merging transcoded segments.                                             |
| `in v start`   | `start_time` (in seconds) of the first video stream in the input video.                                    |
| `out v start`  | `start_time` (in seconds) of the first video stream in the video transcoded without splitting and merging. |
| `mrg v start`  | `start_time` (in seconds) of the first video stream in the merged video.                                   |
| `in a start`   | `start_time` (in seconds) of the first audio stream in the input video.                                    |
| `out v start`  | `start_time` (in seconds) of the first audio stream in the input transcoded without splitting and merging. |
| `mrg v start`  | `start_time` (in seconds) of the first audio stream in the merged video.                                   |

#### Experiment: `segment-split-half-scale`
| video                                    | in duration | out duration | mrg duration | in v start | out v start | mrg v start | in a start | out v start | mrg v start |
|------------------------------------------|-------------|--------------|--------------|------------|-------------|-------------|------------|-------------|-------------|
| numbers-10000-gop-25-hevc.mp4            |  400.000000 |   400.000000 |   399.920000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-10000-gop-25-hevc.mpeg           |  399.720000 |   400.040000 |   399.200000 |   0.580000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-av1.mkv               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-cinepak.cpk           |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.avi             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.mkv             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.mp4             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.flv              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.mkv              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h263.3gp              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.avi              |   10.000000 |    10.080000 |    10.080000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.flv              |   10.080000 |    10.000000 |    10.000000 |   0.080000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.mkv              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.mp4              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-huffyuv.mkv           |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.avi             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.mkv             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.mov             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg1video.m1v        |    0.023353 |     0.018502 |     0.018502 |        N/A |         N/A |         N/A |            |             |             |
| numbers-250-gop-25-mpeg1video.mpeg       |    9.960000 |     9.920000 |     9.960000 |   0.540000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-mpeg2video.mpeg       |    9.960000 |    10.000000 |     9.960000 |   0.540000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-mpeg4.mp4             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg4.mpeg            |    9.960000 |     9.960000 |     9.960000 |   0.500000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-msmpeg4v2.avi         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v2.wmv         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v3.avi         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v3.wmv         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-svq1.mov              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-theora.mkv            |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-theora.ogv            |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v210.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v308.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v408.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v410.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp8.ivf               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp8.webm              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp9.avi               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp9.webm              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-wmv1.asf              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-wmv2.asf              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-y41p.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-yuv4.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| big-buck-bunny-[codec=theora].ogv        |   60.708333 |    60.712727 |    60.708333 |   0.000000 |    0.000000 |    0.000000 |   0.000000 |    0.000000 |             |
| big-bunny-[codec=flv1].flv               |   54.082000 |    54.103000 |    54.232000 |   0.000000 |    0.020000 |    0.020000 |   0.003000 |    0.000000 |    0.000000 |
| ForBiggerBlazes-[codec=h264].mp4         |   15.021667 |    15.047000 |    15.158000 |   0.000000 |    0.000000 |    0.023000 |   0.000000 |    0.000000 |    0.000000 |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   15.045000 |    15.070000 |    15.174000 |   0.000000 |    0.000000 |    0.023031 |   0.000000 |    0.000000 |    0.000000 |
| Panasonic-[codec=vp9].webm               |   46.120000 |    46.126000 |    46.192000 |   0.007000 |    0.007000 |    0.054000 |  -0.007000 |   -0.007000 |   -0.007000 |
| star_trails-[codec=wmv2].wmv             |   21.292000 |    21.292000 |    21.558000 |   0.043000 |    0.043000 |    0.043000 |   0.000000 |    0.000000 |    0.000000 |
| TRA3106-[codec=h263].3gp                 |   16.984000 |    16.984000 |    16.986000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| Beach.mp4                                |   79.743333 |    79.766000 |    79.766000 |   0.000000 |    0.000000 |    0.021016 |   0.000000 |    0.000000 |    0.000000 |
| byger-liten.avi                          |  121.480000 |   121.480000 |   121.480000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| gada.mp4                                 | 1285.781767 |  1285.805000 |  1285.805000 |   0.000000 |    0.000000 |    0.022969 |   0.000000 |    0.000000 |    0.000000 |
| tortoise.mp4                             |  152.170000 |   152.192000 |   152.193000 |   0.000000 |    0.000000 |    0.021000 |   0.000000 |    0.000000 |    0.000000 |
| gada-100-first-segment.mp4               |   15.360000 |    15.360000 |    15.360000 |   0.040000 |    0.000000 |    0.022969 |   0.040000 |    0.000000 |    0.000000 |
| grb_2.m4v                                |   27.862000 |    27.862000 |    27.863000 |   0.033000 |    0.000000 |    0.000000 |            |             |             |

#### Experiment: `segment-split-vp9-convert`
| video                                    | in duration | out duration | mrg duration | in v start | out v start | mrg v start | in a start | out v start | mrg v start |
|------------------------------------------|-------------|--------------|--------------|------------|-------------|-------------|------------|-------------|-------------|
| numbers-10000-gop-25-hevc.mp4            |  400.000000 |   400.000000 |   399.920000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-10000-gop-25-hevc.mpeg           |  399.720000 |   400.040000 |   399.480000 |   0.580000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-av1.mkv               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-cinepak.cpk           |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.avi             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.mkv             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.mp4             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.flv              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.mkv              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h263.3gp              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.avi              |   10.000000 |    10.080000 |    10.000000 |   0.000000 |    0.080000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.flv              |   10.080000 |    10.000000 |    10.000000 |   0.080000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.mkv              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.mp4              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-huffyuv.mkv           |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.avi             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.mkv             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.mov             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg1video.m1v        |    0.023353 |    10.040000 |    10.040000 |        N/A |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg1video.mpeg       |    9.960000 |    10.000000 |    10.000000 |   0.540000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg2video.mpeg       |    9.960000 |    10.000000 |    10.000000 |   0.540000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg4.mp4             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg4.mpeg            |    9.960000 |    10.000000 |    10.040000 |   0.500000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v2.avi         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v2.wmv         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v3.avi         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v3.wmv         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-svq1.mov              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-theora.mkv            |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-theora.ogv            |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v210.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v308.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v408.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v410.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp8.ivf               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp8.webm              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp9.avi               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp9.webm              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-wmv1.asf              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-wmv2.asf              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-y41p.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-yuv4.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| big-buck-bunny-[codec=theora].ogv        |   60.708333 |    60.724000 |    60.731000 |   0.000000 |    0.012000 |    0.000000 |   0.000000 |    0.000000 |             |
| big-bunny-[codec=flv1].flv               |   54.082000 |    54.083000 |    54.166000 |   0.000000 |    0.000000 |    0.000000 |   0.003000 |    0.000000 |    0.000000 |
| ForBiggerBlazes-[codec=h264].mp4         |   15.021667 |    15.026000 |    15.088000 |   0.000000 |    0.003000 |    0.003000 |   0.000000 |    0.000000 |    0.000000 |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   15.045000 |    15.050000 |    15.089000 |   0.000000 |    0.003000 |    0.003000 |   0.000000 |    0.000000 |    0.000000 |
| Panasonic-[codec=vp9].webm               |   46.120000 |    46.122000 |    46.168000 |   0.007000 |    0.003000 |    0.043000 |  -0.007000 |    0.000000 |    0.000000 |
| star_trails-[codec=wmv2].wmv             |   21.292000 |    21.251000 |    21.365000 |   0.043000 |    0.043000 |    0.043000 |   0.000000 |    0.000000 |    0.000000 |
| TRA3106-[codec=h263].3gp                 |   16.984000 |    16.983000 |    16.980000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| Beach.mp4                                |   79.743333 |    79.747000 |    79.765000 |   0.000000 |    0.003000 |    0.003000 |   0.000000 |    0.000000 |    0.000000 |
| byger-liten.avi                          |  121.480000 |   121.480000 |   121.480000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| gada.mp4                                 | 1285.781767 |  1285.785000 |  1285.801000 |   0.000000 |    0.003000 |    0.003000 |   0.000000 |    0.000000 |    0.000000 |
| tortoise.mp4                             |  152.170000 |   152.173000 |   152.193000 |   0.000000 |    0.003000 |    0.003000 |   0.000000 |    0.000000 |    0.000000 |
| gada-100-first-segment.mp4               |   15.360000 |    15.363000 |    15.369000 |   0.040000 |    0.003000 |    0.003000 |   0.040000 |    0.000000 |    0.000000 |
| grb_2.m4v                                |   27.862000 |    27.861000 |    27.859000 |   0.033000 |    0.000000 |    0.000000 |            |             |             |

#### Experiment: `ss-split-half-scale`
| video                                    | in duration | out duration | mrg duration | in v start | out v start | mrg v start | in a start | out v start | mrg v start |
|------------------------------------------|-------------|--------------|--------------|------------|-------------|-------------|------------|-------------|-------------|
| numbers-10000-gop-25-hevc.mp4            |  400.000000 |   400.000000 |   400.400000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-10000-gop-25-hevc.mpeg           |  399.720000 |   400.040000 |   402.840000 |   0.580000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-av1.mkv               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-cinepak.cpk           |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.avi             |   10.000000 |    10.000000 |    30.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.mkv             |   10.000000 |    10.000000 |     9.680000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.mp4             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.flv              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.mkv              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h263.3gp              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.avi              |   10.000000 |    10.080000 |    13.560000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.flv              |   10.080000 |    10.000000 |    14.640000 |   0.080000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.mkv              |   10.000000 |    10.000000 |    13.560000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.mp4              |   10.000000 |    10.000000 |    10.320000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-huffyuv.mkv           |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.avi             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.mkv             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.mov             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg1video.m1v        |    0.023353 |     0.018502 |     0.018502 |        N/A |         N/A |         N/A |            |             |             |
| numbers-250-gop-25-mpeg1video.mpeg       |    9.960000 |     9.920000 |    12.320000 |   0.540000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-mpeg2video.mpeg       |    9.960000 |    10.000000 |    12.200000 |   0.540000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-mpeg4.mp4             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg4.mpeg            |    9.960000 |     9.960000 |    12.080000 |   0.500000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-msmpeg4v2.avi         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v2.wmv         |   10.000000 |    10.000000 |    14.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v3.avi         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v3.wmv         |   10.000000 |    10.000000 |    14.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-svq1.mov              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-theora.mkv            |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-theora.ogv            |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v210.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v308.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v408.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v410.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp8.ivf               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp8.webm              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp9.avi               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp9.webm              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-wmv1.asf              |   10.000000 |    10.000000 |    14.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-wmv2.asf              |   10.000000 |    10.000000 |    14.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-y41p.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-yuv4.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| big-buck-bunny-[codec=theora].ogv        |   60.708333 |    60.712727 |    64.568227 |   0.000000 |    0.000000 |    0.000000 |   0.000000 |    0.000000 |    0.000000 |
| big-bunny-[codec=flv1].flv               |   54.082000 |    54.103000 |    89.760000 |   0.000000 |    0.020000 |    0.020000 |   0.003000 |    0.000000 |    0.000000 |
| ForBiggerBlazes-[codec=h264].mp4         |   15.021667 |    15.047000 |    27.992000 |   0.000000 |    0.000000 |    0.023000 |   0.000000 |    0.000000 |    0.000000 |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   15.045000 |    15.070000 |    15.291000 |   0.000000 |    0.000000 |    0.023031 |   0.000000 |    0.000000 |    0.000000 |
| Panasonic-[codec=vp9].webm               |   46.120000 |    46.126000 |    58.316000 |   0.007000 |    0.007000 |    0.054000 |  -0.007000 |   -0.007000 |   -0.007000 |
| star_trails-[codec=wmv2].wmv             |   21.292000 |    21.292000 |    23.078000 |   0.043000 |    0.043000 |    0.043000 |   0.000000 |    0.000000 |    0.000000 |
| TRA3106-[codec=h263].3gp                 |   16.984000 |    16.984000 |    16.984000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| Beach.mp4                                |   79.743333 |    79.747000 |    79.765000 |   0.000000 |    0.003000 |    0.003000 |   0.000000 |    0.000000 |    0.000000 |
| byger-liten.avi                          |  121.480000 |   121.480000 |   121.480000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| gada.mp4                                 | 1285.781767 |  1285.785000 |  1285.801000 |   0.000000 |    0.003000 |    0.003000 |   0.000000 |    0.000000 |    0.000000 |
| tortoise.mp4                             |  152.170000 |   152.173000 |   152.193000 |   0.000000 |    0.003000 |    0.003000 |   0.000000 |    0.000000 |    0.000000 |
| gada-100-first-segment.mp4               |   15.360000 |    15.360000 |    15.754000 |   0.040000 |    0.000000 |    0.022969 |   0.040000 |    0.000000 |    0.000000 |
| grb_2.m4v                                |   27.862000 |    27.862000 |    28.366000 |   0.033000 |    0.000000 |    0.000000 |            |             |             |

#### Experiment: `segment-split-concat-protocol-merge-half-scale`
| video                                    | in duration | out duration | mrg duration | in v start | out v start | mrg v start | in a start | out v start | mrg v start |
|------------------------------------------|-------------|--------------|--------------|------------|-------------|-------------|------------|-------------|-------------|
| numbers-10000-gop-25-hevc.mp4            |  400.000000 |   400.000000 |    80.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-10000-gop-25-hevc.mpeg           |  399.720000 |   400.040000 |   399.440000 |   0.580000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-av1.mkv               |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-cinepak.cpk           |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.avi             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.mkv             |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-dirac.mp4             |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.flv              |   10.000000 |    10.000000 |     1.960000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-flv1.mkv              |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h263.3gp              |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.avi              |   10.000000 |    10.080000 |    10.080000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.flv              |   10.080000 |    10.000000 |     2.320000 |   0.080000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.mkv              |   10.000000 |    10.000000 |     2.360000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-h264.mp4              |   10.000000 |    10.000000 |     2.360000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-huffyuv.mkv           |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.avi             |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.mkv             |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mjpeg.mov             |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg1video.m1v        |    0.023353 |     0.018502 |     0.018502 |        N/A |         N/A |         N/A |            |             |             |
| numbers-250-gop-25-mpeg1video.mpeg       |    9.960000 |     9.920000 |    10.040000 |   0.540000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-mpeg2video.mpeg       |    9.960000 |    10.000000 |    10.000000 |   0.540000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-mpeg4.mp4             |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-mpeg4.mpeg            |    9.960000 |     9.960000 |    10.000000 |   0.500000 |    0.540000 |    0.540000 |            |             |             |
| numbers-250-gop-25-msmpeg4v2.avi         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v2.wmv         |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v3.avi         |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-msmpeg4v3.wmv         |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-svq1.mov              |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-theora.mkv            |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-theora.ogv            |   10.000000 |    10.000000 |    10.480000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v210.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v308.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v408.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-v410.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp8.ivf               |   10.000000 |    10.000000 |          N/A |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp8.webm              |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp9.avi               |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-vp9.webm              |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-wmv1.asf              |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-wmv2.asf              |   10.000000 |    10.000000 |     2.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-y41p.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| numbers-250-gop-25-yuv4.avi              |   10.000000 |    10.000000 |    10.000000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| big-buck-bunny-[codec=theora].ogv        |   60.708333 |    60.712727 |    61.250000 |   0.000000 |    0.000000 |    0.000000 |   0.000000 |    0.000000 |    0.000000 |
| big-bunny-[codec=flv1].flv               |   54.082000 |    54.103000 |    20.448000 |   0.000000 |    0.020000 |    0.020000 |   0.003000 |    0.000000 |    0.000000 |
| ForBiggerBlazes-[codec=h264].mp4         |   15.021667 |    15.047000 |     4.157000 |   0.000000 |    0.000000 |    0.000000 |   0.000000 |    0.000000 |    0.000000 |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   15.045000 |    15.070000 |     5.039000 |   0.000000 |    0.000000 |    0.000000 |   0.000000 |    0.000000 |    0.000000 |
| Panasonic-[codec=vp9].webm               |   46.120000 |    46.126000 |    10.294000 |   0.007000 |    0.007000 |    0.054000 |  -0.007000 |   -0.007000 |   -0.007000 |
| star_trails-[codec=wmv2].wmv             |   21.292000 |    21.292000 |     4.446000 |   0.043000 |    0.043000 |    0.043000 |   0.000000 |    0.000000 |    0.000000 |
| TRA3106-[codec=h263].3gp                 |   16.984000 |    16.984000 |     3.337000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| Beach.mp4                                |   79.743333 |    79.766000 |    18.000000 |   0.000000 |    0.000000 |    0.000000 |   0.000000 |    0.000000 |    0.000000 |
| byger-liten.avi                          |  121.480000 |   121.480000 |   121.480000 |   0.000000 |    0.000000 |    0.000000 |            |             |             |
| gada.mp4                                 | 1285.781767 |  1285.805000 |   261.120000 |   0.000000 |    0.000000 |    0.000000 |   0.000000 |    0.000000 |    0.000000 |
| tortoise.mp4                             |  152.170000 |   152.192000 |    30.030000 |   0.000000 |    0.000000 |    0.000000 |   0.000000 |    0.000000 |    0.000000 |
| gada-100-first-segment.mp4               |   15.360000 |    15.360000 |     5.120000 |   0.040000 |    0.000000 |    0.000000 |   0.040000 |    0.000000 |    0.000000 |
| grb_2.m4v                                |   27.862000 |    27.862000 |     6.607000 |   0.033000 |    0.000000 |    0.000000 |            |             |             |

### Frame type reports
#### Columns
| column           | description                                                                                                                                                   |
|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `video`          | Name of the video file used as input for the experiment.                                                                                                      |
| `in#`            | Total number of frames in the input video.                                                                                                                    |
| `out#`           | Total number of frames in the video produced by transcoding without splitting and merging.                                                                    |
| `splt in#`       | Total number of frames in all the segments produced by split.                                                                                                 |
| `splt out#`      | Total number of frames in all the transcoded segments used as input for merge.                                                                                |
| `mrg#`           | Total number of frames in the video produced by merging transcoded segments.                                                                                  |
| `in type`        | Types of frames in the input video.                                                                                                                           |
| `out type`       | Types of frames in the video transcoded without merge and split.                                                                                              |
| `splt in type`   | Types of frames in all the segments produced by split.                                                                                                        |
| `splt out type`  | Types of frames in all the transcoded segments used as input for merge.                                                                                       |
| `mrg type`       | Types of frames in the video produced by merging transcoded segments.                                                                                         |
| `#I in`          | Number of I-frames in the input video.                                                                                                                        |
| `#I out`         | Number of I-frames in the video produced by transcoding without splitting and merging.                                                                        |
| `#I splt in`     | Number of I-frames in all the segments produced by split.                                                                                                     |
| `#I splt out`    | Number of I-frames in all the transcoded segments used as input for merge.                                                                                    |
| `#I mrg`         | Number of I-frames in the video produced by merging transcoded segments.                                                                                      |
| `#P in`          | Number of P-frames in the input video.                                                                                                                        |
| `#P out`         | Number of P-frames in the video produced by transcoding without splitting and merging.                                                                        |
| `#P splt in`     | Number of P-frames in all the segments produced by split.                                                                                                     |
| `#P splt out`    | Number of P-frames in all the transcoded segments used as input for merge.                                                                                    |
| `#P mrg`         | Number of P-frames in the video produced by merging transcoded segments.                                                                                      |
| `#B in`          | Number of B-frames in the input video.                                                                                                                        |
| `#B out`         | Number of B-frames in the video produced by transcoding without splitting and merging.                                                                        |
| `#B splt in`     | Number of B-frames in all the segments produced by split.                                                                                                     |
| `#B splt out`    | Number of B-frames in all the transcoded segments used as input for merge.                                                                                    |
| `#B mrg`         | Number of B-frames in the video produced by merging transcoded segments.                                                                                      |
| `in == out`      | Is the sequence of frame types identical between the input video and transcoded video produced without merge and split?                                       |
| `out == mrg`     | Is the sequence of frame types identical between the transcoded video produced without merge and split and the video produced by merging transcoded segments? |
| `in == splt in`  | Is the sequence of frame types identical between the input video and all the segments (non-transcoded)?                                                       |
| `splt in == mrg` | Is the sequence of frame types identical between all the segments (non-transcoded) and the video produced by merging transcoded segments?                     |

#### Experiment: `segment-split-half-scale`
| video                                    | in#   | out#  | splt in# | splt out# | mrg#  | in type | out type | splt in type | splt out type | mrg type | #I in  | #I out | #I splt in | #I splt out | #I mrg | #P in  | #P out | #P splt in | #P splt out | #P mrg | #B in  | #B out | #B splt in | #B splt out | #B mrg | in == out | out == mrg | in == splt in | splt in == mrg |
|------------------------------------------|-------|-------|----------|-----------|-------|---------|----------|--------------|---------------|----------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|-----------|------------|---------------|----------------|
| numbers-10000-gop-25-hevc.mp4            | 10000 | 10000 |     9998 |      9998 |  9998 |     BIP |      BIP |          BIP |           BIP |      BIP |     40 |     48 |         40 |          52 |     52 |   2697 |   3343 |       2697 |        3349 |   3349 |   7263 |   6609 |       7261 |        6597 |   6597 |        no |         no |            no |             no |
| numbers-10000-gop-25-hevc.mpeg           | 10000 | 10002 |     9986 |      9987 |  9987 |     BIP |       IP |          BIP |            IP |       IP |     40 |    834 |         40 |         834 |    834 |   2697 |   9168 |       2697 |        9153 |   9153 |   7263 |      0 |       7249 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-av1.mkv               |   250 |   250 |      250 |       250 |   250 |       ? |      BIP |            ? |           BIP |      BIP |      0 |      3 |          0 |           5 |      5 |      0 |     78 |          0 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-cinepak.cpk           |   250 |   250 |      250 |       250 |   250 |       ? |        ? |            ? |             ? |        ? |      0 |      0 |          0 |           0 |      0 |      0 |      0 |          0 |           0 |      0 |      0 |      0 |          0 |           0 |      0 |       yes |        yes |           yes |            yes |
| numbers-250-gop-25-dirac.avi             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-dirac.mkv             |   250 |   250 |      250 |       250 |   250 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      5 |      0 |     78 |          0 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-dirac.mp4             |   250 |   250 |      250 |       250 |   250 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      5 |      0 |     78 |          0 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.avi              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.flv              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.mkv              |   250 |   250 |      250 |       250 |   250 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      5 |    240 |     79 |        240 |          78 |     78 |      0 |    168 |          0 |         167 |    167 |        no |         no |           yes |             no |
| numbers-250-gop-25-h263.3gp              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.avi              |   250 |   250 |      250 |       250 |   250 |     BIP |       IP |          BIP |            IP |       IP |     12 |     21 |         12 |          21 |     21 |     84 |    229 |         84 |         229 |    229 |    154 |      0 |        154 |           0 |      0 |        no |        yes |           yes |             no |
| numbers-250-gop-25-h264.flv              |   250 |   250 |      250 |       250 |   250 |     BIP |       IP |          BIP |            IP |       IP |     12 |     21 |         12 |          23 |     23 |     84 |    229 |         84 |         227 |    227 |    154 |      0 |        154 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.mkv              |   250 |   250 |      250 |       250 |   250 |     BIP |      BIP |          BIP |           BIP |      BIP |     12 |      4 |         12 |           5 |      5 |     84 |     79 |         84 |          77 |     77 |    154 |    167 |        154 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.mp4              |   250 |   250 |      250 |       250 |   250 |     BIP |      BIP |          BIP |           BIP |      BIP |     12 |      4 |         12 |           5 |      5 |     84 |     79 |         84 |          77 |     77 |    154 |    167 |        154 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-huffyuv.mkv           |   250 |   250 |      250 |       250 |   250 |       ? |      BIP |            ? |           BIP |      BIP |      0 |      3 |          0 |           5 |      5 |      0 |     78 |          0 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.avi             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.mkv             |   250 |   250 |      250 |       250 |   250 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      5 |      0 |     80 |          0 |          78 |     78 |      0 |    167 |          0 |         167 |    167 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.mov             |   250 |   250 |      250 |       250 |   250 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      5 |      0 |     80 |          0 |          78 |     78 |      0 |    167 |          0 |         167 |    167 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg1video.m1v        |   250 |   251 |      250 |       251 |   251 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          21 |     21 |    240 |    230 |        240 |         230 |    230 |      0 |      0 |          0 |           0 |      0 |        no |        yes |           yes |             no |
| numbers-250-gop-25-mpeg1video.mpeg       |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg2video.mpeg       |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg4.mp4             |   250 |   250 |      250 |       250 |   250 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      5 |    240 |     78 |        240 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg4.mpeg            |   250 |   250 |      250 |       251 |   251 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         226 |    226 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v2.avi         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v2.wmv         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v3.avi         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v3.wmv         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-svq1.mov              |   250 |   250 |      250 |       250 |   250 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      5 |    240 |     78 |        240 |          79 |     79 |      0 |    169 |          0 |         166 |    166 |        no |         no |           yes |             no |
| numbers-250-gop-25-theora.mkv            |   250 |   250 |      250 |       250 |   250 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      5 |    240 |     79 |        240 |          78 |     78 |      0 |    168 |          0 |         167 |    167 |        no |         no |           yes |             no |
| numbers-250-gop-25-theora.ogv            |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     22 |         10 |          26 |     26 |    240 |    228 |        240 |         224 |    224 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v210.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v308.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v408.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v410.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp8.ivf               |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp8.webm              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp9.avi               |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp9.webm              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-wmv1.asf              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-wmv2.asf              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-y41p.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-yuv4.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| big-buck-bunny-[codec=theora].ogv        |  1450 |  1449 |     1450 |      1454 |  1454 |      IP |       IP |           IP |            IP |       IP |     27 |    128 |         27 |         130 |    130 |   1423 |   1321 |       1423 |        1324 |   1324 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| big-bunny-[codec=flv1].flv               |  1352 |  1352 |     1352 |      1352 |  1352 |      IP |       IP |           IP |            IP |       IP |      7 |    119 |          7 |         118 |    118 |   1345 |   1233 |       1345 |        1234 |   1234 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| ForBiggerBlazes-[codec=h264].mp4         |   360 |   360 |      360 |       360 |   360 |      IP |      BIP |           IP |           BIP |      BIP |     14 |      6 |         14 |           8 |      8 |    346 |    135 |        346 |         135 |    135 |      0 |    219 |          0 |         217 |    217 |        no |         no |           yes |             no |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   361 |   361 |      361 |       361 |   361 |      IP |      BIP |           IP |           BIP |      BIP |     12 |      8 |         12 |          10 |     10 |    349 |    146 |        349 |         145 |    145 |      0 |    207 |          0 |         206 |    206 |        no |         no |           yes |             no |
| Panasonic-[codec=vp9].webm               |  1152 |  1152 |     1152 |      1152 |  1152 |      IP |       IP |           IP |            IP |       IP |      9 |      9 |          9 |           9 |      9 |   1143 |   1143 |       1143 |        1143 |   1143 |      0 |      0 |          0 |           0 |      0 |       yes |        yes |           yes |            yes |
| star_trails-[codec=wmv2].wmv             |   529 |   530 |      529 |       530 |   530 |      IP |       IP |           IP |            IP |       IP |     45 |     45 |         45 |          46 |     46 |    484 |    485 |        484 |         484 |    484 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| TRA3106-[codec=h263].3gp                 |   509 |   509 |      509 |       509 |   509 |      IP |       IP |           IP |            IP |       IP |     53 |     48 |         53 |          48 |     48 |    456 |    461 |        456 |         461 |    461 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| Beach.mp4                                |  1992 |  1992 |     1992 |      1992 |  1992 |     BIP |      BIP |          BIP |           BIP |      BIP |     27 |      8 |         27 |          10 |     10 |    509 |    502 |        509 |         501 |    501 |   1456 |   1482 |       1456 |        1481 |   1481 |        no |         no |           yes |             no |
| byger-liten.avi                          |  3037 |  3037 |     3037 |      3037 |  3037 |      IP |       IP |           IP |            IP |       IP |     49 |    260 |         49 |         260 |    260 |   2988 |   2777 |       2988 |        2777 |   2777 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| gada.mp4                                 | 32144 | 32144 |    32144 |     32144 | 32144 |     BIP |      BIP |          BIP |           BIP |      BIP |    391 |    236 |        391 |         239 |    239 |  16942 |   9774 |      16942 |        9772 |   9772 |  14811 |  22134 |      14811 |       22133 |  22133 |        no |         no |           yes |             no |
| tortoise.mp4                             |  4560 |  4560 |     4560 |      4560 |  4560 |     BIP |      BIP |          BIP |           BIP |      BIP |     51 |     19 |         51 |          21 |     21 |   1543 |   1230 |       1543 |        1225 |   1225 |   2966 |   3311 |       2966 |        3314 |   3314 |        no |         no |           yes |             no |
| gada-100-first-segment.mp4               |   384 |   384 |      384 |       384 |   384 |     BIP |      BIP |          BIP |           BIP |      BIP |      8 |      6 |          8 |           8 |      8 |    198 |    126 |        198 |         126 |    126 |    178 |    252 |        178 |         250 |    250 |        no |         no |           yes |             no |
| grb_2.m4v                                |   835 |   835 |      835 |       835 |   835 |     BIP |      BIP |          BIP |           BIP |      BIP |      6 |      6 |          6 |           6 |      6 |    226 |    317 |        226 |         314 |    314 |    603 |    512 |        603 |         515 |    515 |        no |         no |           yes |             no |

#### Experiment: `segment-split-vp9-convert`
| video                                    | in#   | out#  | splt in# | splt out# | mrg#  | in type | out type | splt in type | splt out type | mrg type | #I in  | #I out | #I splt in | #I splt out | #I mrg | #P in  | #P out | #P splt in | #P splt out | #P mrg | #B in  | #B out | #B splt in | #B splt out | #B mrg | in == out | out == mrg | in == splt in | splt in == mrg |
|------------------------------------------|-------|-------|----------|-----------|-------|---------|----------|--------------|---------------|----------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|-----------|------------|---------------|----------------|
| numbers-10000-gop-25-hevc.mp4            | 10000 | 10000 |     9998 |      9998 |  9998 |     BIP |       IP |          BIP |            IP |       IP |     40 |     79 |         40 |          80 |     80 |   2697 |   9921 |       2697 |        9918 |   9918 |   7263 |      0 |       7261 |           0 |      0 |        no |         no |            no |             no |
| numbers-10000-gop-25-hevc.mpeg           | 10000 |  9994 |     9986 |      9986 |  9986 |     BIP |       IP |          BIP |            IP |       IP |     40 |     79 |         40 |          80 |     80 |   2697 |   9915 |       2697 |        9906 |   9906 |   7263 |      0 |       7249 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-av1.mkv               |   250 |   250 |      250 |       250 |   250 |       ? |       IP |            ? |            IP |       IP |      0 |      2 |          0 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-cinepak.cpk           |   250 |   250 |      250 |       250 |   250 |       ? |       IP |            ? |            IP |       IP |      0 |      2 |          0 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-dirac.avi             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-dirac.mkv             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-dirac.mp4             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.avi              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.flv              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.mkv              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h263.3gp              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.avi              |   250 |   250 |      250 |       250 |   250 |     BIP |       IP |          BIP |            IP |       IP |     12 |      2 |         12 |           2 |      2 |     84 |    248 |         84 |         248 |    248 |    154 |      0 |        154 |           0 |      0 |        no |        yes |           yes |             no |
| numbers-250-gop-25-h264.flv              |   250 |   250 |      250 |       250 |   250 |     BIP |       IP |          BIP |            IP |       IP |     12 |      2 |         12 |           5 |      5 |     84 |    248 |         84 |         245 |    245 |    154 |      0 |        154 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.mkv              |   250 |   250 |      250 |       250 |   250 |     BIP |       IP |          BIP |            IP |       IP |     12 |      2 |         12 |           5 |      5 |     84 |    248 |         84 |         245 |    245 |    154 |      0 |        154 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.mp4              |   250 |   250 |      250 |       250 |   250 |     BIP |       IP |          BIP |            IP |       IP |     12 |      2 |         12 |           5 |      5 |     84 |    248 |         84 |         245 |    245 |    154 |      0 |        154 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-huffyuv.mkv           |   250 |   250 |      250 |       250 |   250 |       ? |       IP |            ? |            IP |       IP |      0 |      2 |          0 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.avi             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.mkv             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.mov             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg1video.m1v        |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           2 |      2 |    240 |    248 |        240 |         248 |    248 |      0 |      0 |          0 |           0 |      0 |        no |        yes |           yes |             no |
| numbers-250-gop-25-mpeg1video.mpeg       |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg2video.mpeg       |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg4.mp4             |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg4.mpeg            |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v2.avi         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v2.wmv         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v3.avi         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v3.wmv         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-svq1.mov              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-theora.mkv            |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-theora.ogv            |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v210.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v308.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v408.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v410.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp8.ivf               |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp8.webm              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp9.avi               |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp9.webm              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-wmv1.asf              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-wmv2.asf              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-y41p.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-yuv4.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |      2 |        250 |           5 |      5 |      0 |    248 |          0 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| big-buck-bunny-[codec=theora].ogv        |  1450 |  1450 |     1450 |      1450 |  1450 |      IP |       IP |           IP |            IP |       IP |     27 |     12 |         27 |          13 |     13 |   1423 |   1438 |       1423 |        1437 |   1437 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| big-bunny-[codec=flv1].flv               |  1352 |  1352 |     1352 |      1352 |  1352 |      IP |       IP |           IP |            IP |       IP |      7 |     11 |          7 |          14 |     14 |   1345 |   1341 |       1345 |        1338 |   1338 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| ForBiggerBlazes-[codec=h264].mp4         |   360 |   360 |      360 |       360 |   360 |      IP |       IP |           IP |            IP |       IP |     14 |      3 |         14 |           5 |      5 |    346 |    357 |        346 |         355 |    355 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   361 |   361 |      361 |       361 |   361 |      IP |       IP |           IP |            IP |       IP |     12 |      3 |         12 |           5 |      5 |    349 |    358 |        349 |         356 |    356 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| Panasonic-[codec=vp9].webm               |  1152 |  1152 |     1152 |      1152 |  1152 |      IP |       IP |           IP |            IP |       IP |      9 |      9 |          9 |           9 |      9 |   1143 |   1143 |       1143 |        1143 |   1143 |      0 |      0 |          0 |           0 |      0 |       yes |        yes |           yes |            yes |
| star_trails-[codec=wmv2].wmv             |   529 |   529 |      529 |       529 |   529 |      IP |       IP |           IP |            IP |       IP |     45 |      5 |         45 |           6 |      6 |    484 |    524 |        484 |         523 |    523 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| TRA3106-[codec=h263].3gp                 |   509 |   509 |      509 |       509 |   509 |      IP |       IP |           IP |            IP |       IP |     53 |      4 |         53 |           6 |      6 |    456 |    505 |        456 |         503 |    503 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| Beach.mp4                                |  1992 |  1992 |     1992 |      1992 |  1992 |     BIP |       IP |          BIP |            IP |       IP |     27 |     16 |         27 |          17 |     17 |    509 |   1976 |        509 |        1975 |   1975 |   1456 |      0 |       1456 |           0 |      0 |        no |         no |           yes |             no |
| byger-liten.avi                          |  3037 |  3037 |     3037 |      3037 |  3037 |      IP |       IP |           IP |            IP |       IP |     49 |     24 |         49 |          25 |     25 |   2988 |   3013 |       2988 |        3012 |   3012 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| gada.mp4                                 | 32144 | 32144 |    32144 |     32144 | 32144 |     BIP |       IP |          BIP |            IP |       IP |    391 |    252 |        391 |         252 |    252 |  16942 |  31892 |      16942 |       31892 |  31892 |  14811 |      0 |      14811 |           0 |      0 |        no |        yes |           yes |             no |
| tortoise.mp4                             |  4560 |  4560 |     4560 |      4560 |  4560 |     BIP |       IP |          BIP |            IP |       IP |     51 |     36 |         51 |          41 |     41 |   1543 |   4524 |       1543 |        4519 |   4519 |   2966 |      0 |       2966 |           0 |      0 |        no |         no |           yes |             no |
| gada-100-first-segment.mp4               |   384 |   384 |      384 |       384 |   384 |     BIP |       IP |          BIP |            IP |       IP |      8 |      3 |          8 |           3 |      3 |    198 |    381 |        198 |         381 |    381 |    178 |      0 |        178 |           0 |      0 |        no |        yes |           yes |             no |
| grb_2.m4v                                |   835 |   835 |      835 |       835 |   835 |     BIP |       IP |          BIP |            IP |       IP |      6 |      7 |          6 |           8 |      8 |    226 |    828 |        226 |         827 |    827 |    603 |      0 |        603 |           0 |      0 |        no |         no |           yes |             no |

#### Experiment: `ss-split-half-scale`
| video                                    | in#   | out#  | splt in# | splt out# | mrg#  | in type | out type | splt in type | splt out type | mrg type | #I in  | #I out | #I splt in | #I splt out | #I mrg | #P in  | #P out | #P splt in | #P splt out | #P mrg | #B in  | #B out | #B splt in | #B splt out | #B mrg | in == out | out == mrg | in == splt in | splt in == mrg |
|------------------------------------------|-------|-------|----------|-----------|-------|---------|----------|--------------|---------------|----------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|-----------|------------|---------------|----------------|
| numbers-10000-gop-25-hevc.mp4            | 10000 | 10000 |    10007 |     10010 | 10010 |     BIP |      BIP |          BIP |           BIP |      BIP |     40 |     48 |         44 |          52 |     52 |   2697 |   3343 |       2700 |        3354 |   3354 |   7263 |   6609 |       7263 |        6604 |   6604 |        no |         no |            no |             no |
| numbers-10000-gop-25-hevc.mpeg           | 10000 | 10002 |    10067 |     10074 | 10074 |     BIP |       IP |          BIP |            IP |       IP |     40 |    834 |         44 |         843 |    843 |   2697 |   9168 |       2717 |        9231 |   9231 |   7263 |      0 |       7306 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-av1.mkv               |   250 |   250 |      250 |       250 |   250 |       ? |      BIP |            ? |           BIP |      BIP |      0 |      3 |          0 |           5 |      5 |      0 |     78 |          0 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-cinepak.cpk           |   250 |   250 |      250 |       250 |   250 |       ? |        ? |            ? |             ? |        ? |      0 |      0 |          0 |           0 |      0 |      0 |      0 |          0 |           0 |      0 |      0 |      0 |          0 |           0 |      0 |       yes |        yes |           yes |            yes |
| numbers-250-gop-25-dirac.avi             |   250 |   250 |      750 |       750 |   750 |       I |       IP |            I |            IP |       IP |    250 |     21 |        750 |          65 |     65 |      0 |    229 |          0 |         685 |    685 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-dirac.mkv             |   250 |   250 |      242 |       242 |   242 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        242 |           5 |      5 |      0 |     78 |          0 |          76 |     76 |      0 |    169 |          0 |         161 |    161 |        no |         no |            no |             no |
| numbers-250-gop-25-dirac.mp4             |   250 |   250 |      250 |       250 |   250 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      5 |      0 |     78 |          0 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.avi              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.flv              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.mkv              |   250 |   250 |      250 |       250 |   250 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      5 |    240 |     79 |        240 |          78 |     78 |      0 |    168 |          0 |         167 |    167 |        no |         no |           yes |             no |
| numbers-250-gop-25-h263.3gp              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.avi              |   250 |   250 |      329 |       329 |   329 |     BIP |       IP |          BIP |            IP |       IP |     12 |     21 |         16 |          29 |     29 |     84 |    229 |        112 |         300 |    300 |    154 |      0 |        201 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-h264.flv              |   250 |   250 |      366 |       366 |   366 |     BIP |       IP |          BIP |            IP |       IP |     12 |     21 |         17 |          33 |     33 |     84 |    229 |        125 |         333 |    333 |    154 |      0 |        224 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-h264.mkv              |   250 |   250 |      337 |       337 |   337 |     BIP |      BIP |          BIP |           BIP |      BIP |     12 |      4 |         16 |           6 |      6 |     84 |     79 |        114 |         105 |    105 |    154 |    167 |        207 |         226 |    226 |        no |         no |            no |             no |
| numbers-250-gop-25-h264.mp4              |   250 |   250 |      257 |       258 |   258 |     BIP |      BIP |          BIP |           BIP |      BIP |     12 |      4 |         12 |           5 |      5 |     84 |     79 |         87 |          80 |     80 |    154 |    167 |        158 |         173 |    173 |        no |         no |            no |             no |
| numbers-250-gop-25-huffyuv.mkv           |   250 |   250 |      250 |       250 |   250 |       ? |      BIP |            ? |           BIP |      BIP |      0 |      3 |          0 |           5 |      5 |      0 |     78 |          0 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.avi             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.mkv             |   250 |   250 |      250 |       250 |   250 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      5 |      0 |     80 |          0 |          78 |     78 |      0 |    167 |          0 |         167 |    167 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.mov             |   250 |   250 |      250 |       250 |   250 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      5 |      0 |     80 |          0 |          78 |     78 |      0 |    167 |          0 |         167 |    167 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg1video.m1v        |   250 |   251 |      250 |       251 |   251 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          21 |     21 |    240 |    230 |        240 |         230 |    230 |      0 |      0 |          0 |           0 |      0 |        no |        yes |           yes |             no |
| numbers-250-gop-25-mpeg1video.mpeg       |   250 |   250 |      310 |       310 |   310 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         14 |          29 |     29 |    240 |    229 |        296 |         281 |    281 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-mpeg2video.mpeg       |   250 |   250 |      310 |       310 |   310 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         14 |          29 |     29 |    240 |    229 |        296 |         281 |    281 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-mpeg4.mp4             |   250 |   250 |      250 |       250 |   250 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      5 |    240 |     78 |        240 |          77 |     77 |      0 |    169 |          0 |         168 |    168 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg4.mpeg            |   250 |   250 |      302 |       302 |   302 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         14 |          29 |     29 |    240 |    229 |        288 |         273 |    273 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-msmpeg4v2.avi         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v2.wmv         |   250 |   250 |      350 |       350 |   350 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         14 |          33 |     33 |    240 |    229 |        336 |         317 |    317 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-msmpeg4v3.avi         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v3.wmv         |   250 |   250 |      350 |       350 |   350 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         14 |          33 |     33 |    240 |    229 |        336 |         317 |    317 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-svq1.mov              |   250 |   250 |      250 |       250 |   250 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      5 |    240 |     78 |        240 |          79 |     79 |      0 |    169 |          0 |         166 |    166 |        no |         no |           yes |             no |
| numbers-250-gop-25-theora.mkv            |   250 |   250 |      250 |       250 |   250 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      5 |    240 |     79 |        240 |          78 |     78 |      0 |    168 |          0 |         167 |    167 |        no |         no |           yes |             no |
| numbers-250-gop-25-theora.ogv            |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     22 |         10 |          26 |     26 |    240 |    228 |        240 |         224 |    224 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v210.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v308.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v408.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v410.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp8.ivf               |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp8.webm              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp9.avi               |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp9.webm              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      5 |    240 |    248 |        240 |         245 |    245 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-wmv1.asf              |   250 |   250 |      350 |       350 |   350 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         14 |          33 |     33 |    240 |    229 |        336 |         317 |    317 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-wmv2.asf              |   250 |   250 |      350 |       350 |   350 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         14 |          33 |     33 |    240 |    229 |        336 |         317 |    317 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-y41p.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-yuv4.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| big-buck-bunny-[codec=theora].ogv        |  1450 |  1449 |     1558 |      1366 |  1366 |      IP |       IP |           IP |            IP |       IP |     27 |    128 |         32 |         133 |    133 |   1423 |   1321 |       1526 |        1233 |   1233 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| big-bunny-[codec=flv1].flv               |  1352 |  1352 |     2240 |      2240 |  2240 |      IP |       IP |           IP |            IP |       IP |      7 |    119 |         12 |         197 |    197 |   1345 |   1233 |       2228 |        2043 |   2043 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| ForBiggerBlazes-[codec=h264].mp4         |   360 |   360 |      360 |       360 |   360 |      IP |      BIP |           IP |           BIP |      BIP |     14 |      6 |         14 |          10 |     10 |    346 |    135 |        346 |         135 |    135 |      0 |    219 |          0 |         215 |    215 |        no |         no |           yes |             no |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   361 |   361 |      361 |       361 |   361 |      IP |      BIP |           IP |           BIP |      BIP |     12 |      8 |         12 |           9 |      9 |    349 |    146 |        349 |         146 |    146 |      0 |    207 |          0 |         206 |    206 |        no |         no |           yes |             no |
| Panasonic-[codec=vp9].webm               |  1152 |  1152 |     1455 |      1455 |  1455 |      IP |       IP |           IP |            IP |       IP |      9 |      9 |         14 |          14 |     14 |   1143 |   1143 |       1441 |        1441 |   1441 |      0 |      0 |          0 |           0 |      0 |       yes |         no |            no |            yes |
| star_trails-[codec=wmv2].wmv             |   529 |   530 |      560 |       564 |   564 |      IP |       IP |           IP |            IP |       IP |     45 |     45 |         50 |          50 |     50 |    484 |    485 |        510 |         514 |    514 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
| TRA3106-[codec=h263].3gp                 |   509 |   509 |      509 |       509 |   509 |      IP |       IP |           IP |            IP |       IP |     53 |     48 |         53 |          48 |     48 |    456 |    461 |        456 |         461 |    461 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| Beach.mp4                                |  1992 |  1992 |     1992 |      1992 |  1992 |     BIP |      BIP |          BIP |           BIP |      BIP |     27 |      8 |         27 |          10 |     10 |    509 |    502 |        509 |         501 |    501 |   1456 |   1482 |       1456 |        1481 |   1481 |        no |         no |           yes |             no |
| byger-liten.avi                          |  3037 |  3037 |     3037 |      3037 |  3037 |      IP |       IP |           IP |            IP |       IP |     49 |    260 |         49 |         260 |    260 |   2988 |   2777 |       2988 |        2777 |   2777 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| gada.mp4                                 | 32144 | 32144 |    32144 |     32144 | 32144 |     BIP |      BIP |          BIP |           BIP |      BIP |    391 |    236 |        391 |         239 |    239 |  16942 |   9774 |      16942 |        9772 |   9772 |  14811 |  22134 |      14811 |       22133 |  22133 |        no |         no |           yes |             no |
| tortoise.mp4                             |  4560 |  4560 |     4560 |      4560 |  4560 |     BIP |      BIP |          BIP |           BIP |      BIP |     51 |     19 |         51 |          21 |     21 |   1543 |   1230 |       1543 |        1225 |   1225 |   2966 |   3311 |       2966 |        3314 |   3314 |        no |         no |           yes |             no |
| gada-100-first-segment.mp4               |   384 |   384 |      392 |       392 |   392 |     BIP |      BIP |          BIP |           BIP |      BIP |      8 |      6 |          8 |          11 |     11 |    198 |    126 |        204 |         130 |    130 |    178 |    252 |        180 |         251 |    251 |        no |         no |            no |             no |
| grb_2.m4v                                |   835 |   835 |      848 |       850 |   850 |     BIP |      BIP |          BIP |           BIP |      BIP |      6 |      6 |          7 |           8 |      8 |    226 |    317 |        231 |         317 |    317 |    603 |    512 |        610 |         525 |    525 |        no |         no |            no |             no |

#### Experiment: `segment-split-concat-protocol-merge-half-scale`
| video                                    | in#   | out#  | splt in# | splt out# | mrg#  | in type | out type | splt in type | splt out type | mrg type | #I in  | #I out | #I splt in | #I splt out | #I mrg | #P in  | #P out | #P splt in | #P splt out | #P mrg | #B in  | #B out | #B splt in | #B splt out | #B mrg | in == out | out == mrg | in == splt in | splt in == mrg |
|------------------------------------------|-------|-------|----------|-----------|-------|---------|----------|--------------|---------------|----------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|-----------|------------|---------------|----------------|
| numbers-10000-gop-25-hevc.mp4            | 10000 | 10000 |     9998 |      9998 |  2000 |     BIP |      BIP |          BIP |           BIP |      BIP |     40 |     48 |         40 |          52 |     16 |   2697 |   3343 |       2697 |        3349 |    646 |   7263 |   6609 |       7261 |        6597 |   1338 |        no |         no |            no |             no |
| numbers-10000-gop-25-hevc.mpeg           | 10000 | 10002 |     9986 |      9987 |  9987 |     BIP |       IP |          BIP |            IP |       IP |     40 |    834 |         40 |         834 |    834 |   2697 |   9168 |       2697 |        9153 |   9153 |   7263 |      0 |       7249 |           0 |      0 |        no |         no |            no |             no |
| numbers-250-gop-25-av1.mkv               |   250 |   250 |      250 |       250 |    50 |       ? |      BIP |            ? |           BIP |      BIP |      0 |      3 |          0 |           5 |      1 |      0 |     78 |          0 |          77 |     14 |      0 |    169 |          0 |         168 |     35 |        no |         no |           yes |             no |
| numbers-250-gop-25-cinepak.cpk           |   250 |   250 |      250 |       250 |    50 |       ? |        ? |            ? |             ? |        ? |      0 |      0 |          0 |           0 |      0 |      0 |      0 |          0 |           0 |      0 |      0 |      0 |          0 |           0 |      0 |       yes |         no |           yes |             no |
| numbers-250-gop-25-dirac.avi             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-dirac.mkv             |   250 |   250 |      250 |       250 |    50 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      1 |      0 |     78 |          0 |          77 |     14 |      0 |    169 |          0 |         168 |     35 |        no |         no |           yes |             no |
| numbers-250-gop-25-dirac.mp4             |   250 |   250 |      250 |       250 |    50 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      1 |      0 |     78 |          0 |          77 |     14 |      0 |    169 |          0 |         168 |     35 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.avi              |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.flv              |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |      5 |    240 |    229 |        240 |         225 |     45 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-flv1.mkv              |   250 |   250 |      250 |       250 |    50 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      1 |    240 |     79 |        240 |          78 |     15 |      0 |    168 |          0 |         167 |     34 |        no |         no |           yes |             no |
| numbers-250-gop-25-h263.3gp              |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |      5 |    240 |    229 |        240 |         225 |     45 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.avi              |   250 |   250 |      250 |       250 |   250 |     BIP |       IP |          BIP |            IP |       IP |     12 |     21 |         12 |          21 |     21 |     84 |    229 |         84 |         229 |    229 |    154 |      0 |        154 |           0 |      0 |        no |        yes |           yes |             no |
| numbers-250-gop-25-h264.flv              |   250 |   250 |      250 |       250 |    59 |     BIP |       IP |          BIP |            IP |       IP |     12 |     21 |         12 |          23 |      5 |     84 |    229 |         84 |         227 |     54 |    154 |      0 |        154 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.mkv              |   250 |   250 |      250 |       250 |    59 |     BIP |      BIP |          BIP |           BIP |      BIP |     12 |      4 |         12 |           5 |      1 |     84 |     79 |         84 |          77 |     18 |    154 |    167 |        154 |         168 |     40 |        no |         no |           yes |             no |
| numbers-250-gop-25-h264.mp4              |   250 |   250 |      250 |       250 |    59 |     BIP |      BIP |          BIP |           BIP |      BIP |     12 |      4 |         12 |           5 |      1 |     84 |     79 |         84 |          77 |     18 |    154 |    167 |        154 |         168 |     40 |        no |         no |           yes |             no |
| numbers-250-gop-25-huffyuv.mkv           |   250 |   250 |      250 |       250 |    50 |       ? |      BIP |            ? |           BIP |      BIP |      0 |      3 |          0 |           5 |      1 |      0 |     78 |          0 |          77 |     14 |      0 |    169 |          0 |         168 |     35 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.avi             |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.mkv             |   250 |   250 |      250 |       250 |    50 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      1 |      0 |     80 |          0 |          78 |     15 |      0 |    167 |          0 |         167 |     34 |        no |         no |           yes |             no |
| numbers-250-gop-25-mjpeg.mov             |   250 |   250 |      250 |       250 |    50 |       I |      BIP |            I |           BIP |      BIP |    250 |      3 |        250 |           5 |      1 |      0 |     80 |          0 |          78 |     15 |      0 |    167 |          0 |         167 |     34 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg1video.m1v        |   250 |   251 |      250 |       251 |   251 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          21 |     21 |    240 |    230 |        240 |         230 |    230 |      0 |      0 |          0 |           0 |      0 |        no |        yes |           yes |             no |
| numbers-250-gop-25-mpeg1video.mpeg       |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg2video.mpeg       |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg4.mp4             |   250 |   250 |      250 |       250 |    50 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      1 |    240 |     78 |        240 |          77 |     14 |      0 |    169 |          0 |         168 |     35 |        no |         no |           yes |             no |
| numbers-250-gop-25-mpeg4.mpeg            |   250 |   250 |      250 |       251 |   251 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         226 |    226 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v2.avi         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v2.wmv         |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |      5 |    240 |    229 |        240 |         225 |     45 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v3.avi         |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-msmpeg4v3.wmv         |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |      5 |    240 |    229 |        240 |         225 |     45 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-svq1.mov              |   250 |   250 |      250 |       250 |    50 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      1 |    240 |     78 |        240 |          79 |     15 |      0 |    169 |          0 |         166 |     34 |        no |         no |           yes |             no |
| numbers-250-gop-25-theora.mkv            |   250 |   250 |      250 |       250 |    50 |      IP |      BIP |           IP |           BIP |      BIP |     10 |      3 |         10 |           5 |      1 |    240 |     79 |        240 |          78 |     15 |      0 |    168 |          0 |         167 |     34 |        no |         no |           yes |             no |
| numbers-250-gop-25-theora.ogv            |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     22 |         10 |          26 |     26 |    240 |    228 |        240 |         224 |    224 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v210.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v308.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v408.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-v410.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp8.ivf               |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      1 |    240 |    248 |        240 |         245 |     49 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp8.webm              |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      1 |    240 |    248 |        240 |         245 |     49 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp9.avi               |   250 |   250 |      250 |       250 |   250 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |     25 |    240 |    229 |        240 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-vp9.webm              |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |      2 |         10 |           5 |      1 |    240 |    248 |        240 |         245 |     49 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-wmv1.asf              |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |      5 |    240 |    229 |        240 |         225 |     45 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-wmv2.asf              |   250 |   250 |      250 |       250 |    50 |      IP |       IP |           IP |            IP |       IP |     10 |     21 |         10 |          25 |      5 |    240 |    229 |        240 |         225 |     45 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-y41p.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| numbers-250-gop-25-yuv4.avi              |   250 |   250 |      250 |       250 |   250 |       I |       IP |            I |            IP |       IP |    250 |     21 |        250 |          25 |     25 |      0 |    229 |          0 |         225 |    225 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| big-buck-bunny-[codec=theora].ogv        |  1450 |  1449 |     1450 |      1454 |  1454 |      IP |       IP |           IP |            IP |       IP |     27 |    128 |         27 |         130 |    130 |   1423 |   1321 |       1423 |        1324 |   1324 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| big-bunny-[codec=flv1].flv               |  1352 |  1352 |     1352 |      1352 |   510 |      IP |       IP |           IP |            IP |       IP |      7 |    119 |          7 |         118 |     44 |   1345 |   1233 |       1345 |        1234 |    466 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| ForBiggerBlazes-[codec=h264].mp4         |   360 |   360 |      360 |       360 |    99 |      IP |      BIP |           IP |           BIP |      BIP |     14 |      6 |         14 |           8 |      2 |    346 |    135 |        346 |         135 |     45 |      0 |    219 |          0 |         217 |     52 |        no |         no |           yes |             no |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   361 |   361 |      361 |       361 |   120 |      IP |      BIP |           IP |           BIP |      BIP |     12 |      8 |         12 |          10 |      4 |    349 |    146 |        349 |         145 |     57 |      0 |    207 |          0 |         206 |     59 |        no |         no |           yes |             no |
| Panasonic-[codec=vp9].webm               |  1152 |  1152 |     1152 |      1152 |   256 |      IP |       IP |           IP |            IP |       IP |      9 |      9 |          9 |           9 |      2 |   1143 |   1143 |       1143 |        1143 |    254 |      0 |      0 |          0 |           0 |      0 |       yes |         no |           yes |             no |
| star_trails-[codec=wmv2].wmv             |   529 |   530 |      529 |       530 |   109 |      IP |       IP |           IP |            IP |       IP |     45 |     45 |         45 |          46 |     10 |    484 |    485 |        484 |         484 |     99 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| Beach.mp4                                |  1992 |  1992 |     1992 |      1992 |   450 |     BIP |      BIP |          BIP |           BIP |      BIP |     27 |      8 |         27 |          10 |      2 |    509 |    502 |        509 |         501 |    113 |   1456 |   1482 |       1456 |        1481 |    335 |        no |         no |           yes |             no |
| byger-liten.avi                          |  3037 |  3037 |     3037 |      3037 |  3037 |      IP |       IP |           IP |            IP |       IP |     49 |    260 |         49 |         260 |    260 |   2988 |   2777 |       2988 |        2777 |   2777 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| gada.mp4                                 | 32144 | 32144 |    32144 |     32144 |  6528 |     BIP |      BIP |          BIP |           BIP |      BIP |    391 |    236 |        391 |         239 |     61 |  16942 |   9774 |      16942 |        9772 |   2125 |  14811 |  22134 |      14811 |       22133 |   4342 |        no |         no |           yes |             no |
| tortoise.mp4                             |  4560 |  4560 |     4560 |      4560 |   900 |     BIP |      BIP |          BIP |           BIP |      BIP |     51 |     19 |         51 |          21 |      4 |   1543 |   1230 |       1543 |        1225 |    227 |   2966 |   3311 |       2966 |        3314 |    669 |        no |         no |           yes |             no |
| TRA3106-[codec=h263].3gp                 |   509 |   509 |      509 |       509 |   100 |      IP |       IP |           IP |            IP |       IP |     53 |     48 |         53 |          48 |     10 |    456 |    461 |        456 |         461 |     90 |      0 |      0 |          0 |           0 |      0 |        no |         no |           yes |             no |
| gada-100-first-segment.mp4               |   384 |   384 |      384 |       384 |   128 |     BIP |      BIP |          BIP |           BIP |      BIP |      8 |      6 |          8 |           8 |      3 |    198 |    126 |        198 |         126 |     40 |    178 |    252 |        178 |         250 |     85 |        no |         no |           yes |             no |
| grb_2.m4v                                |   835 |   835 |      835 |       835 |   198 |     BIP |      BIP |          BIP |           BIP |      BIP |      6 |      6 |          6 |           6 |      1 |    226 |    317 |        226 |         314 |     72 |    603 |    512 |        603 |         515 |    125 |        no |         no |           yes |             no |

#### Experiment: `segment-split-only`
| video                                    | in#   | splt in# | mrg#  | in type | splt in type | mrg type | #I in  | #I splt in | #I mrg | #P in  | #P splt in | #P mrg | #B in  | #B splt in | #B mrg | in == splt in | splt in == mrg |
|------------------------------------------|-------|----------|-------|---------|--------------|----------|--------|------------|--------|--------|------------|--------|--------|------------|--------|---------------|----------------|
| numbers-10000-gop-25-hevc.mp4            | 10000 |     9998 | 10000 |     BIP |          BIP |      BIP |     40 |         40 |     40 |   2697 |       2697 |   2697 |   7263 |       7261 |   7263 |            no |             no |
| numbers-10000-gop-25-hevc.mpeg           | 10000 |     9986 | 10000 |     BIP |          BIP |      BIP |     40 |         40 |     40 |   2697 |       2697 |   2697 |   7263 |       7249 |   7263 |            no |             no |
| numbers-250-gop-25-av1.mkv               |   250 |      250 |   250 |       ? |            ? |        ? |      0 |          0 |      0 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-cinepak.cpk           |   250 |      250 |   250 |       ? |            ? |        ? |      0 |          0 |      0 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-dirac.avi             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-dirac.mkv             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-dirac.mp4             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-flv1.avi              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-flv1.flv              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-flv1.mkv              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-h263.3gp              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-h264.avi              |   250 |      250 |   250 |     BIP |          BIP |      BIP |     12 |         12 |     12 |     84 |         84 |     84 |    154 |        154 |    154 |           yes |            yes |
| numbers-250-gop-25-h264.flv              |   250 |      250 |   250 |     BIP |          BIP |      BIP |     12 |         12 |     12 |     84 |         84 |     84 |    154 |        154 |    154 |           yes |            yes |
| numbers-250-gop-25-h264.mkv              |   250 |      250 |   250 |     BIP |          BIP |      BIP |     12 |         12 |     12 |     84 |         84 |     84 |    154 |        154 |    154 |           yes |            yes |
| numbers-250-gop-25-h264.mp4              |   250 |      250 |   250 |     BIP |          BIP |      BIP |     12 |         12 |     12 |     84 |         84 |     84 |    154 |        154 |    154 |           yes |            yes |
| numbers-250-gop-25-huffyuv.mkv           |   250 |      250 |   250 |       ? |            ? |        ? |      0 |          0 |      0 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mjpeg.avi             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mjpeg.mkv             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mjpeg.mov             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mpeg1video.m1v        |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mpeg1video.mpeg       |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mpeg2video.mpeg       |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mpeg4.mp4             |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mpeg4.mpeg            |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-msmpeg4v2.avi         |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-msmpeg4v2.wmv         |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-msmpeg4v3.avi         |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-msmpeg4v3.wmv         |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-svq1.mov              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-theora.mkv            |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-theora.ogv            |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-v210.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-v308.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-v408.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-v410.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-vp8.ivf               |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-vp8.webm              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-vp9.avi               |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-vp9.webm              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-wmv1.asf              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-wmv2.asf              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-y41p.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-yuv4.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| big-buck-bunny-[codec=theora].ogv        |  1450 |     1167 |     0 |      IP |           IP |          |     27 |         21 |      0 |   1423 |       1146 |      0 |      0 |          0 |      0 |            no |             no |
| big-bunny-[codec=flv1].flv               |  1352 |     1352 |  1352 |      IP |           IP |       IP |      7 |          7 |      7 |   1345 |       1345 |   1345 |      0 |          0 |      0 |           yes |            yes |
| ForBiggerBlazes-[codec=h264].mp4         |   360 |      360 |   360 |      IP |           IP |       IP |     14 |         14 |     14 |    346 |        346 |    346 |      0 |          0 |      0 |           yes |            yes |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   361 |      361 |   361 |      IP |           IP |       IP |     12 |         12 |     12 |    349 |        349 |    349 |      0 |          0 |      0 |           yes |            yes |
| Panasonic-[codec=vp9].webm               |  1152 |     1152 |  1152 |      IP |           IP |       IP |      9 |          9 |      9 |   1143 |       1143 |   1143 |      0 |          0 |      0 |           yes |            yes |
| star_trails-[codec=wmv2].wmv             |   529 |      529 |   529 |      IP |           IP |       IP |     45 |         45 |     45 |    484 |        484 |    484 |      0 |          0 |      0 |           yes |            yes |
| TRA3106-[codec=h263].3gp                 |   509 |      509 |   509 |      IP |           IP |       IP |     53 |         53 |     53 |    456 |        456 |    456 |      0 |          0 |      0 |           yes |            yes |
| Beach.mp4                                |  1992 |     1992 |  1992 |     BIP |          BIP |      BIP |     27 |         27 |     27 |    509 |        509 |    509 |   1456 |       1456 |   1456 |           yes |            yes |
| byger-liten.avi                          |  3037 |     3037 |  3037 |      IP |           IP |       IP |     49 |         49 |     49 |   2988 |       2988 |   2988 |      0 |          0 |      0 |           yes |            yes |
| gada.mp4                                 | 32144 |    32144 | 32144 |     BIP |          BIP |      BIP |    391 |        391 |    391 |  16942 |      16942 |  16942 |  14811 |      14811 |  14811 |           yes |            yes |
| tortoise.mp4                             |  4560 |     4560 |  4560 |     BIP |          BIP |      BIP |     51 |         51 |     51 |   1543 |       1543 |   1543 |   2966 |       2966 |   2966 |           yes |            yes |
| gada-100-first-segment.mp4               |   384 |      384 |   384 |     BIP |          BIP |      BIP |      8 |          8 |      8 |    198 |        198 |    198 |    178 |        178 |    178 |           yes |            yes |
| grb_2.m4v                                |   835 |      835 |   835 |     BIP |          BIP |      BIP |      6 |          6 |      6 |    226 |        226 |    226 |    603 |        603 |    603 |           yes |            yes |

#### Experiment: `ss-split-only`
| video                                    | in#   | splt in# | mrg#  | in type | splt in type | mrg type | #I in  | #I splt in | #I mrg | #P in  | #P splt in | #P mrg | #B in  | #B splt in | #B mrg | in == splt in | splt in == mrg |
|------------------------------------------|-------|----------|-------|---------|--------------|----------|--------|------------|--------|--------|------------|--------|--------|------------|--------|---------------|----------------|
| numbers-10000-gop-25-hevc.mp4            | 10000 |    10007 | 10002 |     BIP |          BIP |      BIP |     40 |         44 |     40 |   2697 |       2700 |   2697 |   7263 |       7263 |   7265 |            no |             no |
| numbers-10000-gop-25-hevc.mpeg           | 10000 |    10067 | 10061 |     BIP |          BIP |      BIP |     40 |         44 |     44 |   2697 |       2717 |   2713 |   7263 |       7306 |   7304 |            no |             no |
| numbers-250-gop-25-av1.mkv               |   250 |      250 |   250 |       ? |            ? |        ? |      0 |          0 |      0 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-cinepak.cpk           |   250 |      250 |   250 |       ? |            ? |        ? |      0 |          0 |      0 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-dirac.avi             |   250 |      750 |   250 |       I |            I |        I |    250 |        750 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |            no |             no |
| numbers-250-gop-25-dirac.mkv             |   250 |      242 |   242 |       I |            I |        I |    250 |        242 |    242 |      0 |          0 |      0 |      0 |          0 |      0 |            no |            yes |
| numbers-250-gop-25-dirac.mp4             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-flv1.avi              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-flv1.flv              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-flv1.mkv              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-h263.3gp              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-h264.avi              |   250 |      329 |   329 |     BIP |          BIP |      BIP |     12 |         16 |     16 |     84 |        112 |    112 |    154 |        201 |    201 |            no |            yes |
| numbers-250-gop-25-h264.flv              |   250 |      366 |   366 |     BIP |          BIP |      BIP |     12 |         17 |     17 |     84 |        125 |    125 |    154 |        224 |    224 |            no |            yes |
| numbers-250-gop-25-h264.mkv              |   250 |      337 |   337 |     BIP |          BIP |      BIP |     12 |         16 |     16 |     84 |        114 |    114 |    154 |        207 |    207 |            no |            yes |
| numbers-250-gop-25-h264.mp4              |   250 |      257 |   337 |     BIP |          BIP |      BIP |     12 |         12 |     16 |     84 |         87 |    114 |    154 |        158 |    207 |            no |             no |
| numbers-250-gop-25-huffyuv.mkv           |   250 |      250 |   250 |       ? |            ? |        ? |      0 |          0 |      0 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mjpeg.avi             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mjpeg.mkv             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mjpeg.mov             |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mpeg1video.m1v        |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mpeg1video.mpeg       |   250 |      310 |   310 |      IP |           IP |       IP |     10 |         14 |     14 |    240 |        296 |    296 |      0 |          0 |      0 |            no |            yes |
| numbers-250-gop-25-mpeg2video.mpeg       |   250 |      310 |   310 |      IP |           IP |       IP |     10 |         14 |     14 |    240 |        296 |    296 |      0 |          0 |      0 |            no |            yes |
| numbers-250-gop-25-mpeg4.mp4             |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-mpeg4.mpeg            |   250 |      302 |   302 |      IP |           IP |       IP |     10 |         14 |     14 |    240 |        288 |    288 |      0 |          0 |      0 |            no |            yes |
| numbers-250-gop-25-msmpeg4v2.avi         |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-msmpeg4v2.wmv         |   250 |      350 |   350 |      IP |           IP |       IP |     10 |         14 |     14 |    240 |        336 |    336 |      0 |          0 |      0 |            no |            yes |
| numbers-250-gop-25-msmpeg4v3.avi         |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-msmpeg4v3.wmv         |   250 |      350 |   350 |      IP |           IP |       IP |     10 |         14 |     14 |    240 |        336 |    336 |      0 |          0 |      0 |            no |            yes |
| numbers-250-gop-25-svq1.mov              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-theora.mkv            |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-theora.ogv            |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-v210.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-v308.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-v408.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-v410.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-vp8.ivf               |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-vp8.webm              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-vp9.avi               |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-vp9.webm              |   250 |      250 |   250 |      IP |           IP |       IP |     10 |         10 |     10 |    240 |        240 |    240 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-wmv1.asf              |   250 |      350 |   350 |      IP |           IP |       IP |     10 |         14 |     14 |    240 |        336 |    336 |      0 |          0 |      0 |            no |            yes |
| numbers-250-gop-25-wmv2.asf              |   250 |      350 |   350 |      IP |           IP |       IP |     10 |         14 |     14 |    240 |        336 |    336 |      0 |          0 |      0 |            no |            yes |
| numbers-250-gop-25-y41p.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| numbers-250-gop-25-yuv4.avi              |   250 |      250 |   250 |       I |            I |        I |    250 |        250 |    250 |      0 |          0 |      0 |      0 |          0 |      0 |           yes |            yes |
| big-buck-bunny-[codec=theora].ogv        |  1450 |     1558 |  1558 |      IP |           IP |       IP |     27 |         32 |     32 |   1423 |       1526 |   1526 |      0 |          0 |      0 |            no |            yes |
| big-bunny-[codec=flv1].flv               |  1352 |     2240 |  2240 |      IP |           IP |       IP |      7 |         12 |     12 |   1345 |       2228 |   2228 |      0 |          0 |      0 |            no |            yes |
| ForBiggerBlazes-[codec=h264].mp4         |   360 |      360 |   424 |      IP |           IP |       IP |     14 |         14 |     19 |    346 |        346 |    405 |      0 |          0 |      0 |           yes |             no |
| ForBiggerMeltdowns-[codec=mpeg4].mp4     |   361 |      361 |   442 |      IP |           IP |       IP |     12 |         12 |     17 |    349 |        349 |    425 |      0 |          0 |      0 |           yes |             no |
| Panasonic-[codec=vp9].webm               |  1152 |     1455 |  1455 |      IP |           IP |       IP |      9 |         14 |     14 |   1143 |       1441 |   1441 |      0 |          0 |      0 |            no |            yes |
| star_trails-[codec=wmv2].wmv             |   529 |      560 |   560 |      IP |           IP |       IP |     45 |         50 |     50 |    484 |        510 |    510 |      0 |          0 |      0 |            no |            yes |
| TRA3106-[codec=h263].3gp                 |   509 |      509 |   539 |      IP |           IP |       IP |     53 |         53 |     58 |    456 |        456 |    481 |      0 |          0 |      0 |           yes |             no |
| Beach.mp4                                |  1992 |     1996 |  2100 |     BIP |          BIP |      BIP |     27 |         28 |     31 |    509 |        510 |    538 |   1456 |       1458 |   1531 |            no |             no |
| byger-liten.avi                          |  3037 |     3566 |  3566 |      IP |           IP |       IP |     49 |         54 |     54 |   2988 |       3512 |   3512 |      0 |          0 |      0 |            no |            yes |
| gada.mp4                                 | 32144 |    32147 | 32524 |     BIP |          BIP |      BIP |    391 |        391 |    398 |  16942 |      16945 |  17141 |  14811 |      14811 |  14985 |            no |             no |
| tortoise.mp4                             |  4560 |     4569 |  5010 |     BIP |          BIP |      BIP |     51 |         53 |     58 |   1543 |       1547 |   1705 |   2966 |       2969 |   3247 |            no |             no |
| gada-100-first-segment.mp4               |   384 |      392 |   751 |     BIP |          BIP |      BIP |      8 |          8 |     18 |    198 |        204 |    396 |    178 |        180 |    337 |            no |             no |
| grb_2.m4v                                |   835 |      848 |  1592 |     BIP |          BIP |      BIP |      6 |          7 |     14 |    226 |        231 |    433 |    603 |        610 |   1145 |            no |             no |

### Anomalies observed in results
#### Split&merge methods
- `segment-split-half-scale`
    - Most files have correct number of frames both when transcoded with split&merge.
        The only exceptions are `numbers-10000-gop-25-hevc.mp4` and `numbers-10000-gop-25-hevc.mpeg`.
    - Surprisingly there are a few files which have one frame too many or too little when transcoded **without** split&merge.
        These are `star_trails-[codec=wmv2].wmv`, `big-buck-bunny-[codec=theora].ogv`, `numbers-250-gop-25-mpeg1video.m1v`, `numbers-10000-gop-25-hevc.mpeg`.
- `segment-split-vp9-convert`:
    - Most files have correct number of frames both when transcoded with and without split&merge.
        The only exceptions are `numbers-10000-gop-25-hevc.mp4` and `numbers-10000-gop-25-hevc.mpeg`.
- `ss-split-half-scale`
    - Most files have too many frames when merged.
        This split method does not seem worth pursuing.
- `segment-split-concat-protocol-merge-half-scale`
    - Most files are too short when merged.
        Concat protocol merge is unusable with most containers.

#### Videos producing bad merge with ffmpeg segment split and ffmpeg concat demuxer merge
- `numbers-10000-gop-25-hevc.mp4`
    - Incorrect number of frames in the merged file (for all tested split and merge methods)
    - Durations differ slightly.
- `numbers-10000-gop-25-hevc.mpeg`
    - Incorrect number of frames in the merged file (for all tested split and merge methods)
    - Durations differ significantly.
- `big-buck-bunny-[codec=theora].ogv`:
    - Incorrect number of frames in the split segments and in merged file.
    - In some cases the number of frames reported as 0.
    - Sometimes the file transcoded without split&merge is missing a frame but the merged file has the correct number of frames.
    - Warnings from ffmpeg during merge or when inspecting transcoded files with ffprobe.
    - Results for this file might not be completely deterministic.
        For all the other files rerunning the experiments consistently gives the same results but for this one the results changed (improved) after rerunning them.
        The merge result used to be too short and have too little frames.
        Now it seems correct.

        The new results are in the tables above.
        The old results were as follows:
        - durations and timestamps

            | experiment                  | in duration | out duration | mrg duration | in v start | out v start | mrg v start | in a start | out v start | mrg v start |
            |-----------------------------|-------------|--------------|--------------|------------|-------------|-------------|------------|-------------|-------------|
            | `segment-split-half-scale`  |   60.708333 |    60.712727 |    11.973864 |   0.000000 |    0.000000 |             |   0.000000 |    0.000000 |    0.000000 |
            | `segment-split-vp9-convert` |   60.708333 |    60.724000 |    60.752000 |   0.000000 |    0.012000 |             |   0.000000 |    0.000000 |    0.000000 |

        - frame types report

            | experiment                  | in#   | out#  | splt in# | splt out# | mrg#  | in type | out type | splt in type | splt out type | mrg type | #I in  | #I out | #I splt in | #I splt out | #I mrg | #P in  | #P out | #P splt in | #P splt out | #P mrg | #B in  | #B out | #B splt in | #B splt out | #B mrg | in == out | out == mrg | in == splt in | splt in == mrg |
            |-----------------------------|-------|-------|----------|-----------|-------|---------|----------|--------------|---------------|----------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|--------|--------|------------|-------------|--------|-----------|------------|---------------|----------------|
            | `segment-split-half-scale`  |  1450 |  1449 |     1167 |      1168 |     0 |      IP |       IP |           IP |            IP |          |     27 |    128 |         21 |         102 |      0 |   1423 |   1321 |       1146 |        1066 |      0 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |
            | `segment-split-vp9-convert` |  1450 |  1450 |     1167 |      1167 |     0 |      IP |       IP |           IP |            IP |          |     27 |     12 |         21 |          10 |      0 |   1423 |   1438 |       1146 |        1157 |      0 |      0 |      0 |          0 |           0 |      0 |        no |         no |            no |             no |

- `numbers-250-gop-25-mpeg1video.m1v`
    - Sometimes the file transcoded without split&merge is missing a frame but the merged file has the correct number of frames.
- `gada.mp4`
    - Number of frames and duration of the merged file are correct but there are differences in the video.
        Frames differ, often completely, in the file transcoded with and without split&merge.
        The ones after merging seem to be shifted by one frame.
        - This affects other files too (e.g. `grb_2.m4v`).
        - This only happens when scaling. Not when converting to VP9.

Note that all the files for which this method produces incorrect results have problems also when transcoding without split&merge.
This indicates that it's not the splitting or merging methods that are the cause of these problems.

The only significant problem is the frame shift `gada.mp4` and that can be solved by handling audio and video streams separately (see experiments described later in this document).

## 4. Analysis of bad files
These files were available but could not be included in the reports.

### Overview of observed problems
- Errors when using ffprobe on the input file, output file or the segments.
- Missing data in ffprobe output.
- Errors in `segment-split-only` experiment (splitting with ffmpeg segment and merging with concat demuxer without transcoding).
- Errors in `segment-split-half-scale` experiment (splitting with ffmpeg segment, scaling by 0.5 with ffmpeg and merging with concat demuxer).

We have lots of other files to test with so these were not used in the experiments.
We may want to get back to some of them when we get the split&merge properly implemented but it's likely that the libav itself can't work with them and we'll have to just have to detect and reject them.

### Generated videos with numbered frames
##### `numbers-250-gop-25-h261.h261`
- `segment-split-only` experiment: produces merged file but there are problems inspecting it.
    - ffmpeg segment splits the file into 250 segments so 1 frame per segment.
    - `ffprobe` fails to inspect some of these segments:
        ```
        segment-00008.h261: Invalid data found when processing input
        ```
    - ffprobe displays warnings when inspecting the merge file:
        ```
        [h261 @ 0x557de07d2680] Format h261 detected only with low score of 1, misdetection possible!
        [h261 @ 0x557de07d4200] warning: first frame is no keyframe
        ```
    - ffprobe `-show_frames` for the merged file shows `duration` and `bitrate` as `N/A` and lists only 2 frames.
- `segment-split-half-scale` experiment: ffmpeg fails to transcode some of the segments
    ```
    numbers-250-gop-25-h261.h261/split/segment-00003.h261: Invalid data found when processing input
    ```

##### `numbers-250-gop-25-h263p.h263` and `numbers-250-gop-25-h263p.h263`
- `segment-split-only` experiment: produces merged video but inspecting segments with `ffprobe -show_frames` often produces warnings:
    ```
    [h263 @ 0x55bf4de98900] warning: first frame is no keyframe
    ```
    - ffmpeg segment splits the file into 250 segments so 1 frame per segment which looks like the cause and should not be possible without transcoding B- and P- frames to I-frames.
- `segment-split-half-scale` experiment: produces merged video but ffprobe fail to inspect the merged file:
    ```
    merged.h263: Invalid data found when processing input
    ```

##### `numbers-250-gop-25-rawvideo.mkv`
- Errors in ffmpeg segment:
    ```
    [matroska @ 0x563930903b80] Raw RGB is not supported Natively in Matroska, you can use AVI or NUT or
    If you would like to store it anyway using VFW mode, enable allow_raw_vfw (-allow_raw_vfw 1)
    av_interleaved_write_frame(): Invalid argument
    ```
    - Then the command crashes (segmentation fault).

##### `numbers-250-gop-25-dirac.drc`
- `segment-split-only` experiment: merge step fails
    ```
    Output file #0 does not contain any stream
    ```

##### `numbers-250-gop-25-mjpeg.mjpeg`
- `segment-split-only` and `segment-split-half-scale` experiments: merge step produces warnings but succeeds
    ```
   [mjpeg @ 0x561888b53c00] Application provided invalid, non monotonically increasing dts to muxer in stream 0: 1 >= 0 
    ```

##### `numbers-10000-gop-25-hevc.mkv`
- `segment-split-only` experiment: merge step fails
    ```
    [matroska @ 0x55806c7f7680] Can't write packet with unknown timestamp
    av_interleaved_write_frame(): Invalid argument
    ```

##### `numbers-250-gop-25-rv20.rm` and `numbers-250-gop-25-rv10.rm`
- `segment-split-only` experiment: merged file is produced but `ffprobe -show_frames` does not list any frames and lists warnings instead:
    - rv10
        ```
        [rv10 @ 0x56366672cac0] marker missing
        [rv10 @ 0x56366672cac0] Invalid qscale value: 0
        [rv10 @ 0x56366672cac0] HEADER ERROR
        ```
    - rv20
        ```
        [rv20 @ 0x5574a89e0dc0] Invalid qscale value: 0
        [rv20 @ 0x5574a89e0dc0] HEADER ERROR
        ```
- `segment-split-half-scale` experiment: transcoding step fails.
    There's no overall error message but it prints a lot of errors like these:
    - rv10
        ```
        [rv10 @ 0x55bb24686480] marker missing
        [rv10 @ 0x55bb24686480] Invalid qscale value: 0
        [rv10 @ 0x55bb24686480] HEADER ERROR
        Error while decoding stream #0:0: Invalid data found when processing input
        ```
    - rv20
        ```
        [rv20 @ 0x55de7eec7480] Invalid qscale value: 0
        [rv20 @ 0x55de7eec7480] HEADER ERROR
        Error while decoding stream #0:0: Invalid data found when processing input
        ```

##### `numbers-250-gop-25-vp9.mp4`
- `segment-split-only` experiment: merge fails
    ```
    [mp4 @ 0x5574758dc640] Application provided invalid, non monotonically increasing dts to muxer in stream 0: 25088 >= 25088
    av_interleaved_write_frame(): Invalid argument
    ```

##### `numbers-250-gop-25-msmpeg4v2.mpeg`
- `segment-split-only` experiment: merged file is produced but both ffmpeg segment and concat protocol merge produce lots of warnings:
    ```
    [mp3float @ 0x556246d84a00] Header missing
    [mp3float @ 0x556246d84a00] big_values too big
    [mp3float @ 0x556246d84a00] Error while decoding MPEG audio frame.
    ```
    ```
    [mpeg @ 0x55cf4c555680] buffer underflow st=0 bufi=1101 size=1192
    ```
    ```
    [mpeg @ 0x55cf4c555680] packet too large, ignoring buffer limits to mux it
    ```
- `segment-split-half-scale` experiment: transcoding step fails.
    There's no overall error message but (in addition to the warnings from the split step) it prints a lot of errors like these:
    ```
    [mp3float @ 0x5610e283c4c0] Header missing
    Error while decoding stream #0:0: Invalid data found when processing input 
    ```
    ```
    [mp3float @ 0x5610e283c4c0] big_values too big
    [mp3float @ 0x5610e283c4c0] Error while decoding MPEG audio frame.
    Error while decoding stream #0:0: Invalid data found when processing input
    ```

##### `numbers-250-gop-25-msmpeg4v3.mpeg`
- `segment-split-only` experiment: split step fails
    ```
    [mp3float @ 0x55607b9d4f40] Header missing
    [segment @ 0x55607ba08300] sample rate not set
    Could not write header for output file #0 (incorrect codec parameters ?): Invalid argument
    ```

##### `numbers-250-gop-25-rawvideo.mkv`
- `segment-split-only` experiment: no problems
- `segment-split-half-scale` experiment: can't scale by 0.5 because `dvvideo` supports only a few specific resolutions: 720x480, 720x576, 960x720, 1280x1080, 1440x1080

##### `numbers-250-gop-25-hevc.hevc` and `numbers-250-gop-25-h264.h264`
- `segment-split-only` experiment: no problems
- `segment-split-half-scale` experiment: no problems
- These are basically raw H.264/H.265 streams stored in a file.
    `ffprobe -show_streams` for both the input and the merged output returns `N/A` for many properties (`duration`, `start_time`, `bit_rate`, `nb_frames`, etc.) which breaks my error reporter and makes it hard to work with the file.
    The files might be usable but require special handling.

### Videos from the `transcoding_experiments` repository
- `carphone_qcif-[codec=rawvideo].y4m`
    - ffmpeg segment fails:
        ```
        [yuv4mpegpipe @ 0x55634cd79bc0] ERROR: Codec not supported.
        Could not write header for output file #0 (incorrect codec parameters ?): Invalid data found when processing inpu
        ```
- `Dance-[codec=mpeg2video].mpeg`
    - Splitting with ffmpeg segment and merging with concat demuxer without transcoding: no problems
    - Splitting with ffmpeg segment, trascoding to VP9 MKV and merging with concat demuxer: no problems
    - Any experiment with scaling the segments by 0.5: transcoding step fails with:
        ```
        [mpeg1video @ 0x5576d73125c0] MPEG-1/2 does not support 12/1 fps
        Error initializing output stream 0:0 -- Error while opening encoder for output stream #0:0 - maybe incorrect parameters such as bit_rate, rate, width or height
        ```
    - Splitting with ffpmeg input seek (`-ss`): merging step with concat demuxer merge produces lots of warnings like:
        ```
        [mp2 @ 0x5621c3703a40] Header missing
        ```
        ```
        [mpeg @ 0x5621c371d240] buffer underflow st=1 bufi=3331 size=6138
        ```
        ```
        [mpeg @ 0x5621c371d240] packet too large, ignoring buffer limits to mux it
        ```

## 5. Frame types in the test videos

### Frame types in the shorter videos
Snippets below illustrate the internal structure of the tested files on some smaller examples.

Note that these sequences are wrapped on I-frames only for readability.
Each file contains a single, continuous stream of video frames and lines breaks below do **not** represent segment splits.

#### `big-buck-bunny-[codec=theora].ogv`
```
IP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
```

#### `ForBiggerBlazes-[codec=h264].mp4`
```
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPP
I
I
I
I
IPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPP
IP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPP
```

#### `ForBiggerMeltdowns-[codec=mpeg4].mp4`
```
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPP
IP
I
I
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPP
```

#### `Panasonic-[codec=vp9].webm`
```
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
```

#### `star_trails-[codec=wmv2].wmv`
```
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPP
```

#### `TRA3106-[codec=h263].3gp`
```
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPP
IPP
IPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPP
IPPPPPPPPPPP
IPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPP
IPPPPPPPPPPP
IPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPP
IPPPPPPPPPPP
IPPPPPP
IPPPPPPPPPPP
IPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPP
IP
IPPPPP
IP
IPPP
IP
IPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPPPPPP
IPPPPPPP
```

#### `grb_2.m4v`
```
IBBPBBBPBBBPBBBPBBBPBBBPBBBPBBPBBPBBBPBPBBPBBPBPPBPBPBPBPBPBPBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBPBBBPBBBPBBBPBBBPBPBBBPBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBPBBBPBBBPBP
IBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBPBBBPBBBPBBBPBBBPBBPPPP
IPBBBPBPP
IBBBPBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBPBBBPBBBPBBBPBBBPBBP
IBBBPBBBPBBBPBBBPBBBPBPBBBPBBBPBBBPBBBPBPBBBPBPBBBPBBBPBBBPBBBPBPBBBPBBBPBBBPBBBPBBBPBBBPBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBPBBBPBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBP
IBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBP
```

### Frame type changes during split, transcoding and merge
Example for `ForBiggerMeltdowns-[codec=mpeg4].mp4` processed in experiments with and without transcoding:

- split with ffmpeg segment (same in both experiments)
    ```
    input        IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPIPIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPP

    segment 1    IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPIPIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
    segment 2    IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
    segment 3    IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPP
    ```

- merge without transcoding in `segment-split-only` experiment
    ```
    merged       IPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPIPIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIPPPPPPPPPPPPPPPPPPPPPPPPPPP
    ```

- merge with transcoding in `segment-split-half-scale` experiment
    ```
    transcoded 1 IPBBBPPPPBBBPPBBPPPPPBBPBBBPBPPPPPBBBPPBPBBBPBPBBBPBBBPBBBPBBBPBBPPBBPPPIBPPPPIPPPIPPPBBBPBBBPBBBPBBBPBBPPPBPPPBBPBBBPPP
    transcoded 2 IBPPBBBPBBBPBBBPBBBPBBBPBBPBBBPBBPPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBPIBBBPBBPBBPPBPPPPPPPPPIPPPPBBBPBBBPBBBPBBBPBBBPBBBPBBBPPBBPPPPPPPBBBPBBBPBBBPBBP
    transcoded 3 IBBBPBBBPBBBPBPBBBPPPBBBPBBBPBBBPBBBPPBBPBBPPPPPPPBPBBPBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBP

    merged       IPBBBPPPPBBBPPBBPPPPPBBPBBBPBPPPPPBBBPPBPBBBPBPBBBPBBBPBBBPBBBPBBPPBBPPPIBPPPPIPPPIPPPBBBPBBBPBBBPBBBPBBPPPBPPPBBPBBBPPPIBPPBBBPBBBPBBBPBBBPBBBPBBPBBBPBBPPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBPIBBBPBBPBBPPBPPPPPPPPPIPPPPBBBPBBBPBBBPBBBPBBBPBBBPBBBPPBBPPPPPPPBBBPBBBPBBBPBBPIBBBPBBBPBBBPBPBBBPPPBBBPBBBPBBBPBBBPPBBPBBPPPPPPPBPBBPBBPBBBPBBBPBBBPBBBPBBBPBBBPBBBPBP
    ```

### Observations
- All the files are closed-GOP - i.e. none of them have B-frames preceding I-frames.
    - GOP = Group of Pictures, a set of frames starting with an I-frame
- No file contains more than 3 consecutive B frames.
- I-frames are evenly spaced so there should not be any problems with splitting the files into uniform fragments.
- ffmpeg segment and concat demuxer merge without transcoding split and join the files perfectly.
- Transcoding the segments changes frame types but merging them with concat demuxer protocol does not.
    - I've seen cases where transcoding does not change frame types - e.g. for `TRA3106-[codec=h263].3gp`.

## 6. `duration` and `start_time` changes when splitting and merging `gada.mp4`
Sometimes splitting with ffmpeg segment or merging with concat demuxer slightly changes duration or the start time of the streams in the video file.
All of the four problematic files from the CGI team (`Beach.mp4`, `byger-liten.avi`, `gada.mp4`, `tortoise.mp4`) have zero `start_time` for both the audio and the video stream.

I have analyzed start time at all the steps in the `segment-split-only` experiment for `gada.mp4` (split into 7 segments).

Testing was very limited:
- I have not tested this with other splitting and merging methods.
- I have only tested MP4 files.

### Gathered information
- Results with split&merge for `gada.mp4`:

    | File                 | `start_time` |
    |----------------------|--------------|
    | Input file           | 0.000000     |
    | Segment 1            | 0.040000     |
    | Segment 2            | 0.000000     |
    | Segment 3            | 0.000000     |
    | Segment 4            | 0.000000     |
    | Segment 5            | 0.000000     |
    | Segment 6            | 0.000000     |
    | Segment 7            | 0.000000     |
    | Transcoded segment 1 | 0.000000     |
    | Transcoded segment 2 | 0.000000     |
    | Transcoded segment 3 | 0.000000     |
    | Transcoded segment 4 | 0.000000     |
    | Transcoded segment 5 | 0.000000     |
    | Transcoded segment 6 | 0.000000     |
    | Transcoded segment 7 | 0.000000     |
    | Merged file          | 0.022969     |

- Results without split&merge for `gada.mp4`:

    | File                     | `start_time` |
    |--------------------------|--------------|
    | Input file               | 0.000000     |
    | File transcoded directly | 0.000000     |
- Adding `-copyts` before `-i` in the ffmpeg segment command does not affect these timestamps.
- The value of `start_time` differs depending on the file but I can't see any pattern.

### Conclusions
- Splitting with ffmpeg segment adds non-zero `start_time` to the first segment.
- Transcoding resets `start_time`.
- Merging with concat demuxer adds non-zero `start_time` to the output file.

## 7. Reproducing split&merge artifacts observed by the CGI team
### Experiment setup
- Tested on file `Beach.mp4`
- Frames in the input file: 1992
- File is being split into 3 parts (at 30 and 60 seconds) and then merged, without transcoding in between.

### Methods tested
| operation | method          | command                                                                       |
|-----------|-----------------|-------------------------------------------------------------------------------|
| split     | output seek     | `ffmpeg -i <input> -ss <start time> -to <end time> -c copy <output>`          |
| split     | input seek      | `ffmpeg -ss <start time> -to <end time> <input> -c copy <output>`             |
| merge     | concat demuxer  | `ffmpeg -f concat -safe 0 -i <segment list> -c copy <output>`                 |
| merge     | concat protocol | `ffmpeg -i "concat:<segment 1>|<segment 2>|...|<segment n>" -c copy <output>` |

See [ffmpeg wiki > Seeking](https://trac.ffmpeg.org/wiki/Seeking).

### Gathered information
Frame counts in segments and in the merged file:

| split method  | merge method    | segment 1 | segment 2 | segment 3 | segment sum | merged |
|---------------|-----------------|-----------|-----------|-----------|-------------|--------|
| input seek    | concat demuxer  | 751       | 751       | 492       | 1994        | 1996   |
| input seek    | concat protocol | 751       | 751       | 492       | 1994        | 751    |
| output seek   | concat demuxer  | 676       | 676       | 417       | 1769        | 1771   |
| output seek   | concat protocol | 676       | 676       | 417       | 1769        | 676    |

Extra observations:
- Results are identical with and without `-noaccurate_seek` in the split command.
- The size of the output file (in megabytes) in concat protocol merge is the same as the size of the biggest segment.
- The size of the output file (in megabytes) in concat demuxer merge is the same as the total size of all segments.

### Conclusions
- The split with input seek is close to correct but seems to add an extra frame in some segments.
- The split with output seek is completely inaccurate.
- Concat protocol merge does not work correctly for these .mp4 files without any additional processing (e.g. converting them into MPEG-TS streams).
    It seems to just take one segment and ignore the others.
- Concat demuxer merge adds more extra frames on top of the ones already added by the splitter.

## 8. Frame shift in merged `gada.mp4`
### Input
- `gada.mp4`
- File `gada-100-first-segment.mp4` obtained earlier by splitting `gada.mp4` into 100 segments with ffmpeg segment.
    The file is smaller but still reproduces the same problem as long as we're splitting it into segments 

### Observations
The result of splitting, resizing and merging `gada.mp4` is a file that has the correct number of frames but seems to have an extra frame somewhere at the beginning.

This is easy to observe by extracting individual frames from the merged file and looking at frames 60, 61, 62.
In the input file there's a scene transition between frames 60 and 61.
In the merged file the transition is between frames 61 and 62.
There are multiple such scene transitions in the first segment, about every 50-100 frames, and all are shifted.
Diffing the frames shows small but clearly visible differences between earlier frames in the input and merged output.
They're not that clear when looking at the frames themselves - it's hard to tell but I think they're shifted just like the scene transition.

The frame shift has been observed with this particular sequence of operations:
- split with ffmpeg segment into 5 segments.
- scaling to half width and half height with ffmpeg scale filter.
- merge ffmpeg concat demuxer.

The frame shift does not happen in other situations.
For example when:
- The file is only being split and merged (without transcoding).
- Scaling is replaced with reencoding to VP9 in mkv container (other formats have not been tested).
- When splitting the video into fragments shorter than 60 frames.
    This suggests that the shift occurs only in the frames of the first segment.

It has been observed also for some other numbers (e.g. 7 segments) but other splits were not investigated thoroughly.
In all tested cases the first split point is around frame 4500 - far beyond the first shifted frame.

It seems to happen with some other files too but they often lack sharp scene transitions like in `gada.mp4` which makes it harder to tell whether that's the case.
At least some files have clearly visible shapes it the diff while others are virtually identical with the file transcoded without splitting.
- `big-buck-bunny-[codec=theora].ogv` - has large differences between some frames, e.g. frame 288) but no 

### Looking closer at the segments
Segments after split and transcoded segments do not have the frame shift.
The shift seems to be introduced by concat demuxer when the transcoded segments are being merged.

### Experiments: effects of extra processing on the frame shift
#### Extra segment processing
The following processing was applied to each transcoded segment to check if it removes the frame shift:

| Segment processing         | Frame shift present |
|----------------------------|---------------------|
| none                       | yes                 |
| mp4 -> mp4                 | yes                 |
| mp4 -> mkv                 | no                  |
| mp4 -> mkv -> mp4          | yes                 |
| rebuild from frames        | no                  |
| `-pix_fmt yuv444p`         | yes                 |
| strip audio                | no                  |

- `none`: just merge the transcoded segments (this is what we normally do).
- `mp4 -> mp4`: reencode each segment as MP4.
- `mp4 -> mkv`: reencode each segment as MKV.
- `mp4 -> mkv -> mp4`: reencode each segment as MKV and then convert back to MP4.
- `rebuild from frames`: convert each transcoded segment into a sequence of PNG images and build new MP4 files (without audio) from those sequences.
- `-pix_fmt yuv444p`: Use `-pix_fmt` option to make the pixel format identical to the one we get when we do `rebuild from frames` (that's the only significant difference).
- `strip audio`: strip the audio streams from segment files.

#### Different merge methods
The following alternative merge methods were tried to produce files without the frame shift:

| Merge method                     | Audio processing | Frame shift present |
|----------------------------------|------------------|---------------------|
| concat demuxer with `-c copy`    | with video       | yes                 |
| concat demuxer with `-c copy`    | separate merge   | no                  |
| concat demuxer with `-c copy`    | no merge         | no                  |
| concat demuxer without `-c copy` | with video       | yes                 |
| concat protocol merge            | with video       | no                  |
| frame-by-frame merge             | with video       | no                  |

Remarks:
- frame-by-frame merge means converting all the segments into sequences of PNG images and building the final MP4 file from those images.
    The resulting file has no audio.
- Audio processing:
    - `with video`: the audio stream stays in the video files during split, transcoding and merge.
        This is what we nomally do.
    - `separate merge`: the audio stream stays in the video files during split and transcoding but then is extracted from each segment, merged separately and only then combined with the merged video stream.
    - `no merge`: the audio stream is extracted from the input file and video is processed without audio.
        The audio stream is combined with the merged video stream as the last step.
- ffmpeg had problems merging the `aac` audio segments from `gada-100-first-segment.mp4`.
    `separate merge` did produce a merged video and it had no frame shift but there a lot of warnings like `Application provided invalid, non monotonically increasing dts to muxer in stream 0: 224256 >= 223568`.
- concat protocol merge does not add frame shift but the resulting file is not properly merged.
    It has the length of only one segment.

#### Comparison of stream info, frames and packets in files with and without frame shift
Compared files:
- The first transcoded segment of `gada-100-first-segment.mp4`.
- The first transcoded segment of `gada-100-first-segment.mp4` processed using `rebuild from frames` method listed above.

Results for comparison were obtained with:
``` bash
ffprobe -show_streams <video>
ffprobe -show_frames  <video>
ffprobe -show_packets <video>
```

Differences
- The streams differ with:

    | Field              | original segment                         | rebuilt segment         |
    |--------------------|------------------------------------------|-------------------------|
    | `profile`          | `High`                                   | `High 4:4:4 Predictive` |
    | `pix_fmt`          | `yuv420p`                                | `yuv444p`               |
    | `bit_rate`         | 355795                                   | 326101                  |
    | `TAG:handler_name` | `ISO Media file produced by Google Inc.` | `VideoHandler`          |

    - The rebuilt file has no audio stream.

- The frames (at least the ones I've seen) differ only with:

    | Field                  | original segment | rebuilt segment         | Description                                              |
    |------------------------|------------------|-------------------------|----------------------------------------------------------|
    | `pkt_size`             | _varies_         | _varies_                | Size of the packet in bytes.                             |
    | `pkt_pos`              | _varies_         | _varies_                | Position of the packet in the raw stream.                |
    | `pix_fmt`              | `yuv420p`        | `yuv444p`               | Pixel format.                                            |
    | `coded_picture_number` | _varies_         | _varies_                | Sequential number of the packet that contained the frame |
    | `pict_type`            | _varies_         | _varies_                | Frame type (I-, B- or P-frame)                           |

    - The rebuilt file has no audio frames.

- The packets differ with:
    - `pos`
    - `size`
    - The rebuilt file has no audio packets.
- Everything else in the ffprobe output for both files is identical, including duration, timestamps, etc.

Observations:
- The pixel format and the lack of audio track are the only significant differences.
- Differences in packet and frame sizes are probably caused by different pixel formats.
- Positions of B-frames sometimes differ and this is the most likely cause of differences in `coded_picture_number`.

### Conclusions
- The frame shift seems to be caused by something in the audio stream.
    We can easily sidestep the problem by splitting and merging only video and just copying the whole audio track into the merged file.
- ffmpeg seems to be able to handle MKV format without adding the frame shift.
    This is no a viable solution becuause it would force us to use this particular container (which we want to avoid).
- Pixel format has no effect on the frame shift.
    Video duration or start time don't seem to matter either.
- Splitting the file into frames and using them to rebuild the vdieo seems like a good way to get a properly merged file for reference.
- ffmpeg seems to have problems merging AAC audio segments.
    We can avoid it and we probably should.
