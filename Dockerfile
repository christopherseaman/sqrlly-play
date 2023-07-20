FROM node:16-alpine

# Set some build args
ARG FOUNDRY_BASE
ARG FOUNDRY_MAIN
ARG FOUNDRY_VTT_DATA_PATH
ARG FOUNDRY_ZIP_URL
ARG FOUNDRY_DATA_URL
ARG DROPBOX_TOKEN
ARG CRONFREQ
ARG FOUNDRY_HOSTNAME
ARG PORT
ENV FOUNDRY_BASE=${FOUNDRY_BASE}
ENV FOUNDRY_MAIN=${FOUNDRY_MAIN}
ENV FOUNDRY_VTT_DATA_PATH=${FOUNDRY_VTT_DATA_PATH}
ENV FOUNDRY_ZIP_URL=${FOUNDRY_ZIP_URL}
ENV FOUNDRY_DATA_URL=${FOUNDRY_DATA_URL}
ENV DROPBOX_TOKEN=${DROPBOX_TOKEN}
ENV CRONFREQ=${CRONFREQ}
ENV FOUNDRY_HOSTNAME=${FOUNDRY_HOSTNAME}
ENV PORT=${PORT}

ENV UID=1000
ENV GUID=1000

# Set up directories
WORKDIR ${FOUNDRY_BASE}
COPY dot.env ${FOUNDRY_BASE}/dot.env
RUN mkdir -p ${FOUNDRY_BASE}/app
RUN mkdir -p ${FOUNDRY_VTT_DATA_PATH}

# Add some packages for pulling the foundry software and backing up
RUN apk update
RUN apk add --no-cache curl fuse rclone openssl npm jq bash
RUN npm i pm2 -g

# Fetch and extract application
RUN curl -L ${FOUNDRY_ZIP_URL} -o foundryvtt.zip
RUN unzip -q foundryvtt.zip -d ${FOUNDRY_BASE}/app
RUN rm foundryvtt.zip

# Set up backup
COPY rclone-data.sh ${FOUNDRY_BASE}/rclone-data.sh
RUN chmod +x ${FOUNDRY_BASE}/rclone-data.sh
COPY start-foundry.sh ${FOUNDRY_BASE}/start-foundry.sh
RUN chmod +x ${FOUNDRY_BASE}/start-foundry.sh

# the Foundry VTT node application round on port 30000 by default
EXPOSE 30000

CMD ${FOUNDRY_BASE}/start-foundry.sh
