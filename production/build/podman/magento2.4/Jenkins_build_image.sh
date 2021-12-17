#!/bin/bash

set -e

# magento patch versions can have breaking changes / updated dependencies

CONTAINER_NAME=magento2.4.3

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

cd $LOCAL

init_project()
{
    mkdir -p app

    docker run --rm --interactive --tty \
    --user $(id -u):$(id -g) \
    --volume $PWD/app:/app \
    --volume ~/.composer/auth.json:/tmp/auth.json \
    composer create-project --ignore-platform-reqs --repository-url=https://repo.magento.com/ magento/project-community-edition /app

    cd app

    rm -rf $( cat ../excluded_files.txt )

    find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
    find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
    chmod u+x bin/magento

    cd -
}

init_project

podman build -t induxx/cloud:${CONTAINER_NAME} .

#podman push $IMAGEID 188.166.109.224:5000/induxx/cloud:${CONTAINER_NAME}  --tls-verify=false
podman push $IMAGEID registry.induxx.be:5000/induxx/cloud:${CONTAINER_NAME}  --tls-verify=false

rm -rf app
