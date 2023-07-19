#!/usr/bin/env sh

echo "Backup started: $(date)" >> ${FOUNDRY_DATA_DIR}/bkp.log

# Check for previous backup and abort if running
pgrep -x rclone && killall -9 rclone

# Run the backup
# date >> ${FOUNDRY_DATA_DIR}/bkp.log
rclone sync ${FOUNDRY_DATA_DIR} dbx:/Shares/foundry/data --config=/home/foundry/rclone.conf

echo "Backup finished: $(date)" >> ${FOUNDRY_DATA_DIR}/bkp.log
