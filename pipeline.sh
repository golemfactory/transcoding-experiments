#!/bin/bash

TEMPLATE=working-dir/mount/work/params_template.json
PARAMS=working-dir/mount/work/params.json

function run_docker() {
    docker run -it --rm \
    --mount type=bind,source="$(pwd)"/working-dir/mount/work/,target=/golem/work/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/output/,target=/golem/output/ \
    --mount type=bind,source="$(pwd)"/working-dir/mount/resources/,target=/golem/resources/ \
    golemfactory/ffmpeg:0.1 task.py
}

###################################
###################################
echo Splitting... 

echo 
python3 update_params.py $TEMPLATE $PARAMS "context" 1

run_docker

###################################
###################################
echo Transcoding...

mv working-dir/mount/output/* working-dir/mount/resources/.

cd working-dir/mount/resources
playlists=($(ls | grep ].m3u8))
cd ../../../

python3 update_params.py $PARAMS $PARAMS "context" 2

for playlist in "${playlists[@]}"
do 
    echo $playlist
    python3 update_params.py $PARAMS $PARAMS "playlist" "/golem/resources/$playlist"
    run_docker
done

###################################
###################################
echo Merging... 

python3 update_params.py $PARAMS $PARAMS "context" 3

run_docker