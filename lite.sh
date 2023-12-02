#!/bin/bash

# Define load_env()
load_env () {
    set -o allexport
    source $1
    set +o allexport
} 

# Load variables from first arg, else dot.env if exists
DOTFILE=${1:-dot.env}

load_env ${DOTFILE}

# Start Foundry & backup
echo "Starting Foundry..."
pm2 start ${FOUNDRY_MAIN} --name "sqrlly-play"
