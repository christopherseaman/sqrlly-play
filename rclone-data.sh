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

rclone sync ${FOUNDRY_VTT_DATA_PATH} dbx:/Shares/foundry/data \
        --config=${FOUNDRY_BASE}/rclone.conf \
        --stats-one-line -v --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log 
        # --tpslimit 10 --tpslimit-burst 10 --transfers 5 --dropbox-batch-mode sync
