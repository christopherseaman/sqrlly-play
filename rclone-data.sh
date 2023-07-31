#!/usr/bin/env bash

if [ -f ${FOUNDRY_BASE}/dot.env ]; then
    export $(cat dot.env | grep -v "#" | xargs)
fi

rclone sync ${FOUNDRY_VTT_DATA_PATH} dbx:/Shares/foundry/data \
        --config=${FOUNDRY_BASE}/rclone.conf \
        --stats-one-line -v --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log
