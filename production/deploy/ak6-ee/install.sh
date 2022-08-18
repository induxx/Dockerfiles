#!/bin/bash

alias bin_console='docker-compose exec -u build fpm php -d memory_limit=-1 bin/console $@'
alias bash_akeneo='docker-compose exec -u build fpm bash'


bin_console pim:installer:db --catalog vendor/akeneo/pim-enterprise-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/icecat_demo_dev # minimal

bin_console messenger:consume ui_job import_export_job data_maintenance_job --env=prod -v

# production mode
- run : bash_akeneo
- nano .env.local
- edit the .env.local file, this will disable the debug mode
APP_ENV=prod
APP_DEBUG=false
- exit : out of bash
