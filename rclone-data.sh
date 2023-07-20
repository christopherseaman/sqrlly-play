#!/usr/bin/env bash

if [ -f .env ]; then
    source ${FOUNDRY_BASE}/dot.env
fi

rclone sync ${FOUNDRY_VTT_DATA_PATH} dbx:/Shares/foundry/data \
        --config=${FOUNDRY_BASE}/rclone.conf \
        --stats-one-line -v --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log
