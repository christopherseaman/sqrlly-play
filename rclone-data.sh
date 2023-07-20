#!/usr/bin/env bash

source ${FOUNDRY_BASE}/dot.env

rclone sync ${FOUNDRY_VTT_DATA_PATH} dbx:/Shares/foundry/data \
        --config=${FOUNDRY_BASE}/rclone.conf \
        --stats-one-line --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log
