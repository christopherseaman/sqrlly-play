#!/usr/bin/env bash
# pm2 start rclone-data.sh -c '0 * * * *' --no-autorestart --name sqrlly-backup

# source ./dot.env

rclone sync ${FOUNDRY_DATA_DIR} dbx:/Shares/foundry/data --stats-one-line -v --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log
