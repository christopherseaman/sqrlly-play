#!/bin/bash

set -euo pipefail

# Set the default values for the environment variables
NOPUSH=${NOPUSH:-""}

# If ./buildpush.sh --NOPUSH, don't push the image to the registry
while [[ $# -gt 0 ]]; do
    case "$1" in
        --NOPUSH)
            echo "NOPUSH set, not pushing images to the registry"
            export NOPUSH=1
            shift
            ;;
        --RUN)
            echo "RUN set, running the image after successful build"
            export RUN=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set the environment variables from the dot.env file
build_args=()
if [ -f dot.env ]; then
    while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi

        export "$line"
        build_args+=("--build-arg $line")
    done < <(grep -vE '^#|^$' dot.env)
fi

# Set the timestamp for the build in seconds since the epoch
TIMESTAMP=$(date +%s)
HUB_REPO=${HUB_REPO}

# Construct the Docker build command with build_args
docker_build_cmd=("docker build . -t ${HUB_REPO}:${TIMESTAMP}")
docker_build_cmd+=("${build_args[@]}")

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

    # Push the image to the registry unless NOPUSH is set
    if [ -z "${NOPUSH}" ]
    then
        docker push "${HUB_REPO}:latest"
        docker push "${HUB_REPO}:${TIMESTAMP}"
        echo "Pushed ${HUB_REPO}:${TIMESTAMP}, :latest"
    # Run the image if RUN is set
    elif [ -n "${RUN}" ]
    then
        echo "RUN set, running the image"
        docker run -p 30000:30000 "${HUB_REPO}:${TIMESTAMP}"
    fi
else
    echo "Build failed!"
    exit 1
fi
