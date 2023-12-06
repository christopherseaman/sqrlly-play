#!/usr/bin/env bash

# Define load_env()
load_env () {
    set -o allexport
    source $1
    set +o allexport
} 

# Load variables from first arg, else dot.env if exists
DOTFILE=${1:-dot.env}
load_env ${DOTFILE}

# log start of backup in format "2023/12/05 17:30:27 INFO  : UPDATE"
echo "$(date +'%Y/%m/%d %H:%M:%S') META  : Starting backup of ${FOUNDRY_VTT_DATA_PATH}" >> ${FOUNDRY_VTT_DATA_PATH}/bkp.log

rclone sync ${FOUNDRY_VTT_DATA_PATH} dbx:/Shares/foundry/data \
        --config=${FOUNDRY_BASE}/rclone.conf \
        --stats-one-line -v --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log 
        # --tpslimit 10 --tpslimit-burst 10 --transfers 5 --dropbox-batch-mode sync

echo "$(date +'%Y/%m/%d %H:%M:%S') META  : Finished backup of ${FOUNDRY_VTT_DATA_PATH}" >> ${FOUNDRY_VTT_DATA_PATH}/bkp.log
