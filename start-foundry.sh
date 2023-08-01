#!/bin/bash

# Load variables from dot.env if exists, otherwise should be set in environment
if [ -f dot.env ]; then
    while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        export "$line"
    done < <(grep -vE '^#|^$' dot.env)
fi

# Configure rclone
if [ -f ${FOUNDRY_BASE}/rclone.conf ]
  echo "Existing rclone.conf found"
else
  echo "Configuring rclone..."
  echo "[dbx]" > ${FOUNDRY_BASE}/rclone.conf
  echo "type = dropbox" >> ${FOUNDRY_BASE}/rclone.conf
  echo "token = ${DROPBOX_TOKEN}" >> ${FOUNDRY_BASE}/rclone.conf
  echo "rclone config:"
  cat ${FOUNDRY_BASE}/rclone.conf
fi

# Clear backup log if it exists
if [ -f ${FOUNDRY_VTT_DATA_PATH}/bkp.log ]; then
  echo "Clearing backup log..."
  rm ${FOUNDRY_VTT_DATA_PATH}/bkp.log
fi

# Fetch data snapshot
echo "Fetching data snapshot..."
curl -L ${FOUNDRY_DATA_URL} -o ${FOUNDRY_BASE}/data.zip
unzip -q ${FOUNDRY_BASE}/data.zip -d ${FOUNDRY_BASE}
rm ${FOUNDRY_BASE}/data.zip
if rclone sync dbx:/Shares/foundry/data ${FOUNDRY_VTT_DATA_PATH} \
          --config=${FOUNDRY_BASE}/rclone.conf \
          --stats-one-line -v --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log
then
  echo "Data snapshot fetched successfully."
else
  echo "Data snapshot fetch failed."
  echo "rclone config:"
  cat ${FOUNDRY_BASE}/rclone.conf
  echo "Backup log:"
  cat ${FOUNDRY_VTT_DATA_PATH}/bkp.log
  exit 1
fi


# Local settings for Foundry
echo "Configuring Foundry..."
if [ -z "${FOUNDRY_SSL_CERT}" ]
then
  echo "No SSL cert specified, skipping HTTPS"
else
  echo "SSL cert specified, setting up HTTPS"
  jq '.sslCert = env.FOUNDRY_SSL_CERT |
      .sslKey = env.FOUNDRY_SSL_KEY  |
    .dataPath = env.FOUNDRY_VTT_DATA_PATH |
    .hostname = env.FOUNDRY_HOSTNAME' ${FOUNDRY_VTT_DATA_PATH}/Config/options.jq.json > ${FOUNDRY_VTT_DATA_PATH}/Config/options.json
fi

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

pm2 logs
