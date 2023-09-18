#!/usr/bin/env bash

if [ -f dot.env ]; then
    while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        export "$line"
    done < <(grep -vE '^#|^$' dot.env)
fi

rclone sync ${FOUNDRY_VTT_DATA_PATH} dbx:/Shares/foundry/data \
        --config=${FOUNDRY_BASE}/rclone.conf \
        --stats-one-line -v --log-file ${FOUNDRY_VTT_DATA_PATH}/bkp.log 
        # --tpslimit 10 --tpslimit-burst 10 --transfers 5 --dropbox-batch-mode sync
