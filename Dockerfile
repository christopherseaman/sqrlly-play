FROM node:16-alpine

# Set some build args
ARG CRON_CMD 
ARG FOUNDRY_ZIP_URL
ARG FOUNDRY_DATA_URL
ARG FOUNDRY_BASE
ARG FOUNDRY_MAIN
ARG FOUNDRY_VTT_DATA_PATH
ARG DROPBOX_TOKEN
ARG FOUNDRY_HOSTNAME
ARG PORT
ENV CRON_CMD=${CRON_CMD}
ENV FOUNDRY_ZIP_URL=${FOUNDRY_ZIP_URL}
ENV FOUNDRY_DATA_URL=${FOUNDRY_DATA_URL}
ENV FOUNDRY_BASE=${FOUNDRY_BASE}
ENV FOUNDRY_MAIN=${FOUNDRY_MAIN}
ENV FOUNDRY_VTT_DATA_PATH=${FOUNDRY_VTT_DATA_PATH}
ENV DROPBOX_TOKEN=${DROPBOX_TOKEN}
ENV FOUNDRY_HOSTNAME=${FOUNDRY_HOSTNAME}
ENV PORT=${PORT}

ENV UID=1000
ENV GUID=1000

# Set up directories
COPY dot.env ${FOUNDRY_BASE}/dot.env
RUN mkdir -p ${FOUNDRY_BASE}/app
RUN mkdir -p ${FOUNDRY_VTT_DATA_PATH}

# Add some packages for pulling the foundry software and backing up
RUN apk update
RUN apk add --no-cache curl fuse rclone openssl npm jq bash
RUN npm i pm2 -g

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

CMD ${FOUNDRY_BASE}/start-foundry.sh
