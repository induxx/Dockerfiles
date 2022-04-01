#!/bin/bash

# usage: ./Jenkins_build_image.sh <CLOUD_NAME> <GIT_REPO>
# example: bash ./production/build/docker/akeneo/ak5/Jenkins_build_image.sh ak5-ee-pdf induxx/akeneo-ee-pdf-demo

CLOUD_NAME=${1:-ak5}
GIT_REPO=${2:-induxx/akeneo-ee}

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

cd $LOCAL

init_project()
{
    rm -rf app && mkdir -p app

    git clone git@github.com:${GIT_REPO}.git app

    cp .env.local app/.env.local

    mkdir -p app/var/install app/var/file_storage/asset app/var/file_storage/catalog
    tar -xvf ../../../fixtures/ak5/retail_store/asset.tar -C app/var/file_storage/
    tar -xvf ../../../fixtures/ak5/retail_store/catalog.tar -C app/var/file_storage/
    cp f ../../../fixtures/ak5/retail_store/akeneo_pim.sql.gz app/var/install/

    cd app

    bash bin/init
    rm -rf $( cat ../excluded_files.txt )

    cd -
}

init_project

docker build -t induxx/cloud:${CLOUD_NAME} .

# ansible setup some stuff here like the scripts, cron

docker push induxx/cloud:${CLOUD_NAME}

rm -rf app
