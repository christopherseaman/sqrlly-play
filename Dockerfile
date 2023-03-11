FROM node:16-alpine

# "* * * * * /home/foundry/rclone-data.sh"
ARG CRON_CMD 

# Shared dbx link ending in ?dl=1
ARG FOUNDRY_ZIP_URL
ARG FOUNDRY_DATA_URL

# From rclone dropbox setups
ARG DROPBOX_TOKEN

# ARG PORT ## 30000

ENV FOUNDRY_APP_DIR=/home/foundry/app

# This is where persistence data is stored (make it a volume)
ENV FOUNDRY_DATA_DIR=/home/foundry/data

ENV UID=1000
ENV GUID=1000

# Add some packages for pulling the foundry software and backing up
RUN apk update
RUN apk add --no-cache curl fuse rclone openssl npm
RUN deluser node
RUN npm i pm2 -g

# Set up directories
RUN mkdir -p ${FOUNDRY_APP_DIR}
RUN mkdir -p ${FOUNDRY_DATA_DIR}

# Fetch and extract application
WORKDIR ${FOUNDRY_APP_DIR}
RUN curl -L ${FOUNDRY_ZIP_URL} -o foundryvtt.zip
RUN unzip -q foundryvtt.zip
RUN rm foundryvtt.zip

# Fetch data snapshot
WORKDIR ${FOUNDRY_DATA_DIR}
RUN curl -L ${FOUNDRY_DATA_URL} -o data.zip
RUN unzip -q data.zip

# Configure rclone
RUN echo "[dbx]" > /home/foundry/rclone.conf
RUN echo "type = dropbox" >> /home/foundry/rclone.conf
RUN echo "token = ${DROPBOX_TOKEN}" >> /home/foundry/rclone.conf
RUN rclone sync dbx:/Shares/foundry/data ${FOUNDRY_DATA_DIR} --config=/home/foundry/rclone.conf --verbose

# Set up backup
COPY rclone-data.sh /home/foundry/rclone-data.sh
RUN chmod +x /home/foundry/rclone-data.sh
RUN rm /home/foundry/data/bkp.log
RUN echo "${CRON_CMD}" >> /var/spool/cron/crontabs/root
RUN cat /var/spool/cron/crontabs/root

# the Foundry VTT node application round on port 30000 by default
EXPOSE 30000
CMD crond && pm2-runtime ${FOUNDRY_APP_DIR}/resources/app/main.js -- --headless --dataPath=${FOUNDRY_DATA_DIR}
