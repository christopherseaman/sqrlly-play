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
REMOTE="dbx:/Shares/foundry/data"
OPTIONS="--config=${FOUNDRY_BASE}/rclone.conf --checksum -v --stats-one-line --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log"
EXCLUDE="--exclude=*.log --exclude=*.lock --exclude=.DS_Store --exclude=LOCK --exclude=LOG --exclude=LOG.old"

# Log start of backup
echo "$(date +'%Y/%m/%d %H:%M:%S') META  : Starting backup of ${FOUNDRY_VTT_DATA_PATH}" >> ${FOUNDRY_VTT_DATA_PATH}/bkp.log

# Run rclone sync
rclone sync ${FOUNDRY_VTT_DATA_PATH} ${REMOTE} ${OPTIONS} ${EXCLUDE}
rclone copy ${FOUNDRY_VTT_DATA_PATH}/bkp.log ${REMOTE} ${OPTIONS}

# Log end of backup
echo "$(date +'%Y/%m/%d %H:%M:%S') META  : Finished backup of ${FOUNDRY_VTT_DATA_PATH}" >> ${FOUNDRY_VTT_DATA_PATH}/bkp.log
echo "" >> ${FOUNDRY_VTT_DATA_PATH}/bkp.log
