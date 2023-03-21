#!/usr/bin/env sh

echo "Backup started: $(date)" >> ${FOUNDRY_DATA_DIR}/bkp.log

# Check if Foundry is running and if backup has already run at least once
# if [pgrep -x "node" >/dev/null] && [test -f ${FOUNDRY_DATA_DIR}/bkp.log];
# then 
#     echo "Foundry still running :)"
# else
#     if [test -f ${FOUNDRY_DATA_DIR}/bkp.log];
#     then
#         echo "Foundry stopped, kicking"
#         node ${FOUNDRY_APP_DIR}/resources/app/main.js --headless --dataPath=${FOUNDRY_DATA_DIR}
#     else
#         echo "First time through, touch nothing until backed up"
#     fi
# fi

# Check for previous backup and abort if running
pgrep -x rclone && killall -9 rclone

# Run the backup
# date >> ${FOUNDRY_DATA_DIR}/bkp.log
rclone sync ${FOUNDRY_DATA_DIR} dbx:/Shares/foundry/data --config=/home/foundry/rclone.conf

echo "Backup finished: $(date)" >> ${FOUNDRY_DATA_DIR}/bkp.log
