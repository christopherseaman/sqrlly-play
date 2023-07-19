#!/bin/bash

source ${FOUNDRY_BASE}/dot.env

jq '.sslCert = env.FOUNDRY_SSL_CERT |
     .sslKey = env.FOUNDRY_SSL_KEY  |
   .dataPath = env.FOUNDRY_VTT_DATA_PATH' Config/options.jq > Config/options.json

pm2 start ${FOUNDRY_MAIN} --name "sqrlly-play"

pm2 start rclone-data.sh -c '0 * * * *' --no-autorestart --name sqrlly-backup

