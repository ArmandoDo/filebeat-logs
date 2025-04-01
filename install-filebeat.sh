#!/bin/bash

## This script install the dockerize version of Filebeat in your
## local environment. Run the build script before start the installation
##
## Usage:
## ./install-filebeat.sh

# Load env variables
source .env

### Delete the character "/" in the end of the string
export LOGS_FOLDER="${LOGS_FOLDER%/}"

## Container registry
export REGISTRY_NAME="development"
# Filebeat
export APP_NAME="filebeat-${ELASTIC_INDEX}"
export APP_TAG="8.6.2"

## Get the OS
OS_TYPE=$(uname)

generate_docker_compose_file() {
    envsubst < docker-compose.template.yml > docker-compose-${APP_NAME}.yml
}

## Install docker image on linux
install_on_linux() {
    generate_docker_compose_file
    stop_container
    docker compose --file docker-compose-${APP_NAME}.yml up --detach ${APP_NAME}

}

### Stop docker container
stop_container() {
    docker compose --file docker-compose-${APP_NAME}.yml stop ${APP_NAME}
    docker compose --file docker-compose-${APP_NAME}.yml rm --force ${APP_NAME}
}

## Main function
main() {
    echo "${OS_TYPE} detected. Starting the installation..."
    # Verify the OS
    case "${OS_TYPE}" in
        "Darwin")
            echo "install_darwin"
            ;;
        "Linux")
            install_on_linux
            ;;
        *)
            echo "System isn't supported by this script: ${OS_TYPE}"
            echo "Please contact to the support team."
            exit 1
            ;;
    esac

    echo "${APP_NAME} docker image deployed on host..."
}

main