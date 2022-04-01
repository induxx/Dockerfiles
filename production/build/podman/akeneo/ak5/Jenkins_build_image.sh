#!/bin/bash

# usage: ./Jenkins_build_image.sh <CLOUD_NAME> <GIT_REPO>
# example: bash ./production/build/podman/akeneo/ak5/Jenkins_build_image.sh ak5-ee-pdf induxx/akeneo-ee-pdf-demo
# this will build the image without a repositor
# example: bash ./production/build/podman/akeneo/ak5/Jenkins_build_image.sh ak5-ee

CLOUD_NAME=${1:-ak5}
GIT_REPO=${2}

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

cd $LOCAL

rm -rf app && mkdir -p app

init_project()
{
    git clone git@github.com:${GIT_REPO}.git app

    cp .env.local app/.env.local

    cd app

    bash bin/init

    rm -rf $( cat ../excluded_files.txt )

    cd -
}

if [ ! -z "${GIT_REPO}" ]; then
    echo "GIT_REPO is set"
    init_project
fi

set -e

podman build -t induxx/cloud:${CLOUD_NAME} .

IMAGEID=$(podman images | grep ${CLOUD_NAME} | awk '{print $3}')

podman push ${IMAGEID} registry.induxx.be:5000/induxx/cloud:${CLOUD_NAME} --tls-verify=false

set +e

# cleanup
podman rmi ${IMAGEID}
rm -rf app
