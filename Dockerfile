FROM node:16-alpine

# "* * * * * /home/foundry/rclone-data.sh"
ARG CRON_CMD 

# Shared dbx link ending in ?dl=1
ARG FOUNDRY_ZIP_URL
ARG FOUNDRY_DATA_URL
ARG FOUNDRY_HOSTNAME

# From rclone dropbox setups
ARG DROPBOX_TOKEN
# ARG PORT ## 30000
ENV FOUNDRY_BASE=/home/foundry

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

# Fetch data snapshot
WORKDIR ${FOUNDRY_VTT_DATA_PATH}
RUN curl -L ${FOUNDRY_DATA_URL} -o data.zip
RUN unzip -q data.zip

# Configure rclone
RUN echo "[dbx]" > ${FOUNDRY_BASE}/rclone.conf
RUN echo "type = dropbox" >> ${FOUNDRY_BASE}/rclone.conf
RUN echo "token = ${DROPBOX_TOKEN}" >> ${FOUNDRY_BASE}/rclone.conf
RUN rclone sync dbx:/Shares/foundry/data ${FOUNDRY_VTT_DATA_PATH} --config=${FOUNDRY_BASE}/rclone.conf

# Set up backup
COPY rclone-data.sh ${FOUNDRY_BASE}/rclone-data.sh
RUN chmod +x ${FOUNDRY_BASE}/rclone-data.sh
COPY start-foundry.sh ${FOUNDRY_BASE}/start-foundry.sh
RUN chmod +x ${FOUNDRY_BASE}/start-foundry.sh
RUN rm ${FOUNDRY_VTT_DATA_PATH}/bkp.log
RUN touch ${FOUNDRY_VTT_DATA_PATH}/bkp.log
RUN echo "${CRON_CMD}" >> /var/spool/cron/crontabs/root
RUN cat /var/spool/cron/crontabs/root

# Dump environment for startup script
RUN touch ${FOUNDRY_BASE}/dot.env
RUN echo "export FOUNDRY_BASE=${FOUNDRY_BASE}" >> ${FOUNDRY_BASE}/dot.env
RUN echo "export FOUNDRY_VTT_DATA_PATH=${FOUNDRY_VTT_DATA_PATH}" >> ${FOUNDRY_BASE}/dot.env
RUN echo "export FOUNDRY_MAIN=${FOUNDRY_BASE}/app/resources/app/main.js" >> ${FOUNDRY_BASE}/dot.env
RUN echo "export FOUNDRY_HOSTNAME=${FOUNDRY_HOSTNAME}" >> ${FOUNDRY_BASE}/dot.env

# the Foundry VTT node application round on port 30000 by default
EXPOSE 30000

CMD bash ${FOUNDRY_BASE}/start-foundry.sh
