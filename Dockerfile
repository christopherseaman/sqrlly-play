FROM node:16-alpine

# Set some build args
ARG CRON_CMD 
ARG DROPBOX_TOKEN
ARG FOUNDRY_ZIP_URL
ARG FOUNDRY_DATA_URL
ARG FOUNDRY_BASE
ARG FOUNDRY_MAIN
ARG FOUNDRY_VTT_DATA_PATH
ARG FOUNDRY_HOSTNAME
ARG PORT

# This is where persistence data is stored (make it a volume)
ENV FOUNDRY_VTT_DATA_PATH=/home/foundry/data
ENV FOUNDRY_MAIN=${FOUNDRY_BASE}/app/resources/app/main.js
ENV UID=1000
ENV GUID=1000

# Add some packages for pulling the foundry software and backing up
RUN apk update
RUN apk add --no-cache curl fuse rclone openssl npm jq bash
RUN npm i pm2 -g

# Set up directories
RUN mkdir -p ${FOUNDRY_BASE}/app
RUN mkdir -p ${FOUNDRY_VTT_DATA_PATH}

# Fetch and extract application
WORKDIR ${FOUNDRY_BASE}/app
RUN curl -L ${FOUNDRY_ZIP_URL} -o foundryvtt.zip
RUN unzip -q foundryvtt.zip
RUN rm foundryvtt.zip
COPY dot.env ${FOUNDRY_BASE}/dot.env

# Configure rclone
RUN echo "[dbx]" > ${FOUNDRY_BASE}/rclone.conf
RUN echo "type = dropbox" >> ${FOUNDRY_BASE}/rclone.conf
RUN echo "token = ${DROPBOX_TOKEN}" >> ${FOUNDRY_BASE}/rclone.conf

# Set up backup
COPY rclone-data.sh ${FOUNDRY_BASE}/rclone-data.sh
RUN chmod +x ${FOUNDRY_BASE}/rclone-data.sh
COPY start-foundry.sh ${FOUNDRY_BASE}/start-foundry.sh
RUN chmod +x ${FOUNDRY_BASE}/start-foundry.sh
RUN echo "${CRON_CMD}" >> /var/spool/cron/crontabs/root
RUN cat /var/spool/cron/crontabs/root

# the Foundry VTT node application round on port 30000 by default
EXPOSE 30000

CMD bash ${FOUNDRY_BASE}/start-foundry.sh
