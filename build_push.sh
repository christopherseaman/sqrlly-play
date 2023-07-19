#! /bin/sh

# If ./buildpush.sh --NOPUSH, don't push the image to the registry
if [ "$1" = "--NOPUSH" ]
then
    export NOPUSH=1
fi

# Set the timestamp for the build in seconds since the epoch
TIMESTAMP=$(date +%s)
HUB_REPO='sqrlly/play'

if [ -e dot.env ]
then
    source dot.env
    echo "Environment set"
else
    exit "Environment file not found"
fi

docker rmi ${HUB_REPO}:latest
# If the build succeeds, push the image to the registry
echo "Building image ${HUB_REPO}:${TIMESTAMP}"
if docker build . -t ${HUB_REPO}:${TIMESTAMP} \
        --build-arg CRON_CMD="${CRON_CMD}" \
        --build-arg FOUNDRY_ZIP_URL=${FOUNDRY_ZIP_URL} \
        --build-arg FOUNDRY_DATA_URL=${FOUNDRY_DATA_URL} \
        --build-arg FOUNDRY_HOSTNAME=${FOUNDRY_HOSTNAME} \
        --build-arg DROPBOX_TOKEN=${DROPBOX_TOKEN} ;
then
    echo "Build succeeded!"
    docker tag ${HUB_REPO}:${TIMESTAMP} ${HUB_REPO}:latest
    # if NOPUSH is set, don't push the latest tag
    if [ -z ${NOPUSH} ]
    then
        docker push ${HUB_REPO}:latest
        docker push ${HUB_REPO}:${TIMESTAMP}
        echo "Pushed ${HUB_REPO}:${TIMESTAMP}, :latest"
    else
        echo "NOPUSH set, not pushing images to registry"
        exit 0
    fi
else
    exit "Build failed!"
fi