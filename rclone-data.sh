#!/usr/bin/env bash

source ${FOUNDRY_VTT_DATA_PATH}/dot.env

rclone sync ${FOUNDRY_VTT_DATA_PATH} dbx:/Shares/foundry/data --stats-one-line -v --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log
