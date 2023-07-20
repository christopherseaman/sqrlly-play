#!/bin/bash

source ${FOUNDRY_BASE}/dot.env

# Fetch data snapshot
curl -L ${FOUNDRY_DATA_URL} -o ${FOUNDRY_BASE}/data.zip
unzip -q ${FOUNDRY_BASE}/data.zip -d ${FOUNDRY_BASE}
rclone sync dbx:/Shares/foundry/data ${FOUNDRY_VTT_DATA_PATH} --config=${FOUNDRY_BASE}/rclone.conf
rm ${FOUNDRY_VTT_DATA_PATH}/bkp.log
touch ${FOUNDRY_VTT_DATA_PATH}/bkp.log

# Local settings for Foundry
jq '.sslCert = env.FOUNDRY_SSL_CERT |
     .sslKey = env.FOUNDRY_SSL_KEY  |
   .dataPath = env.FOUNDRY_VTT_DATA_PATH |
   .hostname = env.FOUNDRY_HOSTNAME' ${FOUNDRY_VTT_DATA_PATH}/Config/options.jq.json > ${FOUNDRY_VTT_DATA_PATH}/Config/options.json

# Start Foundry & backup
pm2 start ${FOUNDRY_MAIN} --name "sqrlly-play"

pm2 start ${FOUNDRY_BASE}/rclone-data.sh -c '0 * * * *' --no-autorestart --name sqrlly-backup

pm2 logs