#!/bin/bash

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

source "${LOCAL}/.env.local"

name="${1:-${MAGENTO_CONTAINER_NAME}}-mag24"

podman stop "${name}-app";
podman stop "${name}-elasticsearch-7.9";
podman stop "${name}-mysql";
podman stop "${name}-rabbitmq-3";
podman pod stop "${name}-pod";
