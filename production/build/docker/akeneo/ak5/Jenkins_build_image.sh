#!/bin/bash

GIT_REPO=induxx/akeneo-ee

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
    cd -
    rm -rf $( cat excluded_files.txt )
}

init_project

docker build -t induxx/cloud:ak5-ee .

# ansible setup some stuff here like the scripts, cron

docker push induxx/cloud:ak5-ee

rm -rf app
