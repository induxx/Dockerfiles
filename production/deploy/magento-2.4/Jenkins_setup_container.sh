#!/bin/bash

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

source "${LOCAL}/.env.local"

MAGENTO_CONTAINER_NAME="${1:-${MAGENTO_CONTAINER_NAME}}-mag24"

alias bin_magento='podman exec -it -u build -w /build/app ${MAGENTO_CONTAINER_NAME} bin/magento $@'

bin_magento setup:install \
--base-url=http://localhost:8080 \
--db-host=${APP_DATABASE_HOST} \
--db-name=${APP_DATABASE_NAME} \
--db-user=${APP_DATABASE_USER} \
--db-password=${APP_DATABASE_PASSWORD} \
--amqp-host=127.0.0.1 \
--amqp-port=5672 \
--amqp-user=guest \
--amqp-password=guest \
--elasticsearch-host=${APP_INDEX_HOST} \
--elasticsearch-port=${APP_INDEX_PORT} \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@example.com \
--admin-user=${ADMIN_USERNAME} \
--admin-password=${ADMIN_PASSWORD} \
--language=${LANGUAGE} \
--currency=${CURRENY} \
--timezone=${TIMEZONE} \
--use-rewrites=1

# issue with the magento 2FA during login
bin_magento module:disable Magento_TwoFactorAuth
bin_magento setup:di:compile

# magento std setup
bin_magento deploy:mode:set production #developer
bin_magento cache:enable
bin_magento cache:flush
bin_magento setup:static-content:deploy -f
bin_magento cron:install --force
bin_magento indexer:reindex

# daemons consumers
# TODO: add systemd queue daemon to userland
bin_magento queue:consumers:start media.storage.catalog.image.resize &