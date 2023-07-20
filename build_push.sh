#!/bin/bash

set -euo pipefail

# If ./buildpush.sh --NOPUSH, don't push the image to the registry
if [ "$1" = "--NOPUSH" ]
then
    echo "NOPUSH set, not pushing images to registry"
    export NOPUSH=1
fi

# Set the environment variables from the dot.env file
if [ -e dot.env ]
then
    source dot.env
    echo "Environment set"
else
    echo "Environment file not found"
    exit 1
fi

# Set the timestamp for the build in seconds since the epoch
TIMESTAMP=$(date +%s)
HUB_REPO=${HUB_REPO}

# Helper function to expand nested variables and remove single quotes if any
expand_var() {
    local IFS=' '
    local var_value="${*#*=}"
    printf '%s=%s' "${*%%=*}" "${var_value//\'/}"
}

# Set up build args
build_args=()
while IFS= read -r line; do
    eval_line=$(expand_var "$line")
    build_args+=("--build-arg \"$eval_line\"")
done < <(grep -vE '^#|^$' dot.env)

# Construct the Docker build command with build_args
docker_build_cmd=("docker build . -t ${HUB_REPO}:${TIMESTAMP}")
for arg in "${build_args[@]}"; do
    docker_build_cmd+=("$arg")
done

# Announce the build command
echo "Running Docker build command:"
printf "%s \n" "${docker_build_cmd[0]}"
for (( i = 1; i < ${#docker_build_cmd[@]}; i++ )); do
    printf "\t\t%s \n" "${docker_build_cmd[i]}"
done

# Remove the latest tag so we can replace it
docker rmi -f "${HUB_REPO}:latest" || true  # Ignore error if the image doesn't exist

# Build the Docker image
if eval "${docker_build_cmd[@]}"
then
    echo "Build succeeded!"
    docker tag "${HUB_REPO}:${TIMESTAMP}" "${HUB_REPO}:latest"
    # if NOPUSH is set, don't push the latest tag
    if [ -z "${NOPUSH}" ]
    then
        docker push "${HUB_REPO}:latest"
        docker push "${HUB_REPO}:${TIMESTAMP}"
        echo "Pushed ${HUB_REPO}:${TIMESTAMP}, :latest"
    else
        exit 0
    fi
else
    echo "Build failed!"
    exit 1
fi
