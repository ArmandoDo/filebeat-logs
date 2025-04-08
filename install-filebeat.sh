#!/bin/bash

## This script install the dockerize version of Filebeat in your
## local environment. Run the build script before start the installation
##
## Usage:
## ./install-filebeat.sh
# set -ex

## Container registry
export REGISTRY_NAME="development"
# Filebeat
export APP_TAG="8.6.2"

## Get the OS
OS_TYPE=$(uname)

## Install docker image on linux
install_filebeat() {
    stop_container
    ${DOCKER_COMPOSE_COMMAND} --file ${DOCKER_COMPOSE_FILE} up --detach ${APP_NAME}

}

# Set up the docker compose command available on the server
set_up_docker_compose_command() {
    if command -v docker-compose &> /dev/null; then
        export DOCKER_COMPOSE_COMMAND="docker-compose"
    elif command -v docker compose &> /dev/null; then
        export DOCKER_COMPOSE_COMMAND="docker compose"
    else
        echo "Docker Compose is not installed or started in your system.
        Please install the service."
        echo "Exiting..."

        exit 1
    fi
}

# Set up the environment variable file .env
set_up_env_variable_file() {
    if ! source .env; then
        echo "Missing .env file with the environment variables. Please create the .env file"
        exit 1
    fi
    
    ### Delete the character "/" in the end of the string
    export LOGS_FOLDER="${LOGS_FOLDER%/}"
}

## Stop docker container
stop_container() {
    ${DOCKER_COMPOSE_COMMAND} --file ${DOCKER_COMPOSE_FILE} stop ${ELASTICSEARCH_APP_NAME}
    ${DOCKER_COMPOSE_COMMAND} --file ${DOCKER_COMPOSE_FILE} rm --force ${ELASTICSEARCH_APP_NAME}
}

# Verify if the Docker engine is installed on the system
verify_docker_engine() {
    # Verify if service is installed
    if ! command -v docker &> /dev/null; then
        echo "Docker Engine is not installed in your system. Please install the service..."
        echo "Exiting..."
        exit 1
    fi

    # Verify if service is running
    if ! docker info &> /dev/null; then
        echo "Docker engine is installed, but not started. Please launch the service..."
        echo "Exiting..."
        exit 1
    fi
}

## Main function
main() {
    echo "${OS_TYPE} detected. Starting the installation..."
    # Verify the OS
    case "${OS_TYPE}" in
        "Darwin")
            verify_docker_engine
            set_up_docker_compose_command
            set_up_env_variable_file
            # Docker compose filename
            export APP_NAME="filebeat-${ELASTIC_INDEX}"
            export DOCKER_COMPOSE_FILE="docker-compose-${ELASTIC_INDEX}.darwin.yml"
            # Replace env variable
            sed -e "s|\${ELASTIC_INDEX}|$ELASTIC_INDEX|g" docker-compose.darwin.template.yml > ${DOCKER_COMPOSE_FILE}
            install_filebeat
            ;;
        "Linux")
            verify_docker_engine
            set_up_docker_compose_command
            set_up_env_variable_file
            # Docker compose filename
            export APP_NAME="filebeat-${ELASTIC_INDEX}"
            export DOCKER_COMPOSE_FILE="docker-compose-${ELASTIC_INDEX}.ubuntu.yml"
            # Replace env variables
            envsubst < docker-compose.ubuntu.template.yml > ${DOCKER_COMPOSE_FILE}
            install_filebeat
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