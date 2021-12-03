#!/bin/bash

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

source "${LOCAL}/.env.local"

name="${1:-${MAGENTO_CONTAINER_NAME}}-mag24"

bash podman_stop

podman rm "${name}-app";
podman rm "${name}-elasticsearch-7.9";
podman rm "${name}-mysql";
podman rm "${name}-rabbitmq-3";
podman pod rm "${name}-pod";
