#!/bin/bash

source dot.env

pm2 start ${FOUNDRY_MAIN} --name "sqrlly-play"

pm2 start rclone-data.sh -c '0 * * * *' --no-autorestart --name sqrlly-backup

