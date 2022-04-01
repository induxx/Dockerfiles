#!/bin/bash

set -e

# magento patch versions can have breaking changes / updated dependencies

# build process is meant for magento 2.4 and above
# takes about 10 minutes to build

# usage bash ./production/build/podman/mag24/Jenkins_build_image.sh

CONTAINER_NAME=magento2.4.3
GIT_REPO_BRANCH=magento/project-community-edition:2.4.3-p1 # magento/project-community-edition:2.4.3 or magento/project-enterprise-edition:2.4.3

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
    composer create-project --ignore-platform-reqs --repository-url=https://repo.magento.com/ ${GIT_REPO_BRANCH} /app

    cd app

    rm -rf $( cat ../excluded_files.txt )

    find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
    find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
    chmod u+x bin/magento

    cd -
}

init_project

set -e

podman build -t induxx/cloud:${CONTAINER_NAME} .

IMAGEID=$(podman images | grep ${CONTAINER_NAME} | awk '{print $3}')

podman push ${IMAGEID} registry.induxx.be:5000/induxx/cloud:${CONTAINER_NAME} --tls-verify=false

set +e

# cleanup
podman rmi ${IMAGEID}
rm -rf app
