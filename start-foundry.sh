#!/bin/bash

# Define load_env()
load_env () {
    set -o allexport
    source $1
    set +o allexport
} 

# Load variables from first arg, else dot.env if exists
load_env dot.env

# Check for dependencies: rclone, jq, pm2
MISSING_DEPS=0
if ! command -v rclone &> /dev/null
then
    echo "rclone could not be found, please install it and try again"
    MISSING_DEPS=1
fi
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install it and try again"
    MISSING_DEPS=1
fi
if ! command -v pm2 &> /dev/null
then
    echo "pm2 could not be found, please install it and try again"
    MISSING_DEPS=1
fi
if [ $MISSING_DEPS -eq 1 ]
then
    exit 1
fi

# Configure rclone
if [ -f ${FOUNDRY_BASE}/rclone.conf ]
then
  echo "Existing rclone.conf found"
elif [ -z "${DROPBOX_TOKEN}" ]
then
  echo "No Dropbox token specified or existing rclone.conf found, aborting."
  exit 1
else
  echo "Configuring rclone..."
  echo "[dbx]" > ${FOUNDRY_BASE}/rclone.conf
  echo "type = dropbox" >> ${FOUNDRY_BASE}/rclone.conf
  echo "token = ${DROPBOX_TOKEN}" >> ${FOUNDRY_BASE}/rclone.conf
fi

# Fetch data snapshot
if [ -f ${FOUNDRY_BASE}/data.zip ] || [ -d ${FOUNDRY_VTT_DATA_PATH} ]
then
  echo "Existing snapshot found"
else
  echo "Fetching data snapshot..."
  curl -L ${FOUNDRY_DATA_URL} -o ${FOUNDRY_BASE}/data.zip
  unzip -q ${FOUNDRY_BASE}/data.zip -d ${FOUNDRY_BASE}
  rm ${FOUNDRY_BASE}/data.zip
fi

# Clear backup log if it exists
if [ -f ${FOUNDRY_VTT_DATA_PATH}/bkp.log ]; then
  echo "Clearing backup log..."
  rm ${FOUNDRY_VTT_DATA_PATH}/bkp.log
fi

# Local settings for Foundry
# echo "Configuring Foundry..."
# if [ -z "${FOUNDRY_SSL_CERT}" ]
# then
#   echo "No SSL cert specified in env, skipping HTTPS"
# else
#   echo "SSL cert specified, setting up HTTPS"
#   jq '.sslCert = env.FOUNDRY_SSL_CERT |
#       .sslKey = env.FOUNDRY_SSL_KEY  |
#     .dataPath = env.FOUNDRY_VTT_DATA_PATH |
#     .hostname = env.FOUNDRY_HOSTNAME' ${FOUNDRY_VTT_DATA_PATH}/Config/options.jq.json > ${FOUNDRY_VTT_DATA_PATH}/Config/options.json
# fi

# Start Foundry & backup
echo "Starting Foundry and rclone ..."
pm2 start ${FOUNDRY_MAIN} --name "sqrlly-play"

# If NO_BACKUP is set, then skip starting the backup cron
if [ -z "${NO_BACKUP}" ]
then
  echo "Starting backup cron..."
  pm2 start ${FOUNDRY_BASE}/rclone-data.sh -c "${CRONFREQ}" --no-autorestart --name sqrlly-backup
else
  echo "Skipping backup cron... NO_BACKUP=${NO_BACKUP}"
fi

# Debug
# pm2 logs
