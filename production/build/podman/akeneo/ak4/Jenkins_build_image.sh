#!/bin/bash

# usage: ./Jenkins_build_image.sh <CLOUD_NAME> <GIT_REPO>
# example: bash ./production/build/podman/akeneo/ak4/Jenkins_build_image.sh ak5-ee-pdf induxx/akeneo-ee-pdf-demo

CLOUD_NAME=${1:-ak4}
GIT_REPO=${2:-induxx/akeneo-ee}

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

cd $LOCAL

init_project()
{
    rm -rf app && mkdir -p app

    git clone git@github.com:${GIT_REPO}.git app

    cp .env.local app/.env.local

    cd app

    bash bin/init

    rm -rf $( cat ../excluded_files.txt )

    cd -
}

init_project

set -e

podman build -t induxx/cloud:${CLOUD_NAME} .

IMAGEID=$(podman images | grep ${CLOUD_NAME} | awk '{print $3}')

podman push ${IMAGEID} registry.induxx.be:5000/induxx/cloud:${CLOUD_NAME} --tls-verify=false

set +e

# cleanup
podman rmi ${IMAGEID}
rm -rf app
