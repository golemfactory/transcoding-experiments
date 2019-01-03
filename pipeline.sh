#!/usr/bin/env bash

TEMPLATE="working-dir/mount/work/params_template.json"
PARAMS="working-dir/mount/work/params.json"

PSNR_LOG="working-dir/mount/output/psnr.txt"
PSNR_FRAMES="/golem/output/psnr_frames.txt"

SSIM_LOG="working-dir/mount/output/ssim.txt"
SSIM_FRAMES="/golem/output/ssim_frames.txt"

METADATA_REF="working-dir/mount/output/metadata_ref.json"
METADATA_OUT="working-dir/mount/output/metadata_out.json"

INPUT="/golem/resources/Jellyfish.mp4"
OUTPUT="/golem/output/output.mp4"
REFERENCE="/golem/output/Jellyfish_TC.mp4"

IMAGE="golemfactory/ffmpeg:0.2"

###################################
###################################
echo Cleanup...

./clean.sh

###################################
###################################
echo Splitting...

python3 update_params.py ${TEMPLATE} ${PARAMS} "context" 1

./task.sh ${IMAGE}

###################################
###################################
echo Transcoding...

mv working-dir/mount/output/* working-dir/mount/resources/.
cd working-dir/mount/resources
playlists=($(ls | grep ].m3u8))
cd ../../../

python3 update_params.py ${PARAMS} ${PARAMS} "context" 2
python3 update_params.py ${PARAMS} ${PARAMS} "use_playlist" 1

for playlist in "${playlists[@]}"
do
    echo ${playlist}
    python3 update_params.py ${PARAMS} ${PARAMS} "track" "/golem/resources/$playlist"
    ./task.sh ${IMAGE}
done

###################################
###################################
echo Merging...

python3 update_params.py ${PARAMS} ${PARAMS} "context" 3

./task.sh ${IMAGE}

###################################
###################################
echo Transcoding reference video...

python3 update_params.py ${PARAMS} ${PARAMS} "context" 2
python3 update_params.py ${PARAMS} ${PARAMS} "use_playlist" 0
python3 update_params.py ${PARAMS} ${PARAMS} "track" ${INPUT}

./task.sh ${IMAGE}

###################################
###################################
echo PSNR verification...

./psnr.sh ${IMAGE} ${OUTPUT} ${REFERENCE} ${PSNR_FRAMES} ${PSNR_LOG}

###################################
###################################
echo SSIM verification...

./ssim.sh ${IMAGE} ${OUTPUT} ${REFERENCE} ${SSIM_FRAMES} ${SSIM_LOG}

###################################
###################################
echo Metadata...

./metadata.sh ${IMAGE} ${OUTPUT} ${METADATA_OUT}
./metadata.sh ${IMAGE} ${REFERENCE} ${METADATA_REF}

###################################
###################################
echo Output keyframes...
./keyframes.sh ${IMAGE} ${OUTPUT}

echo Reference keyframes...
./keyframes.sh ${IMAGE} ${REFERENCE}

###################################
###################################
echo ""
echo Summary...

python3 compare_video.py ${PSNR_LOG} ${SSIM_LOG} ${METADATA_OUT} ${METADATA_REF}


