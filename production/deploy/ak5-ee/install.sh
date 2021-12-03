#!/bin/bash

alias bin_console='docker-compose exec -u build fpm php -d memory_limit=-1 bin/console $@'

bin_console pim:installer:db --catalog vendor/akeneo/pim-enterprise-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/icecat_demo_dev # minimal

bin_console akeneo:batch:job-queue-consumer-daemon --env=dev -v