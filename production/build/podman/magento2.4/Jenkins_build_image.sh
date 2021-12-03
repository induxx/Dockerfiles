#!/bin/bash

set -e

CONTAINER_NAME=magento2.4.3

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

cd $LOCAL

init_project()
{
    rm -rf app && mkdir -p app

    docker run --rm --interactive --tty \
    --user $(id -u):$(id -g) \
    --volume $PWD/app:/app \
    --volume ~/.composer/auth.json:/tmp/auth.json \
    composer create-project --ignore-platform-reqs --repository-url=https://repo.magento.com/ magento/project-community-edition /app

    cd app

    find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
    find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
    chmod u+x bin/magento

    cd -

    rm -rf $( cat excluded_files.txt )
}

init_project

podman build -t induxx/cloud:${CONTAINER_NAME} .

podman push induxx/cloud:${CONTAINER_NAME}

rm -rf app
