#!/bin/bash

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

source "${LOCAL}/.env.local"

name="${1:-${MAGENTO_CONTAINER_NAME}}-mag24"
pod="${name}-pod"

podman pod create --name="${pod}" --publish=8080:80

podman run -d \
    --pod="${pod}" \
    --name="${name}-app" \
    induxx/cloud-magento2.4

podman run -d \
    --pod="${pod}" \
    --name="${name}-mysql" \
    -e MYSQL_ROOT_PASSWORD="${APP_DATABASE_ROOT_PASSWORD}" -e MYSQL_USER="${APP_DATABASE_USER}" -e MYSQL_DATABASE="${APP_DATABASE_NAME}" -e MYSQL_PASSWORD="${APP_DATABASE_PASSWORD}" \
    docker.io/library/mysql:latest --default-authentication-plugin=mysql_native_password 

podman run -d \
     --pod="${pod}" \
     --name="${name}-elasticsearch-7.9" \
     -e ES_JAVA_OPTS="-Xms512m -Xmx512m" -e discovery.type='single-node' -e xpack.security.enabled="false" \
     docker.io/library/elasticsearch:7.9.3

podman run -d \
    --pod="${pod}" \
    --name="${name}-rabbitmq-3" \
    docker.io/library/rabbitmq:3