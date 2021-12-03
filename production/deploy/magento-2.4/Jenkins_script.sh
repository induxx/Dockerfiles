#!/bin/bash

LOCAL=$(pwd)
LOCAL=$LOCAL"/$(dirname "$0")"

# here we are going to create a new app image that contains the magento2.4 source files
# after building it will auto_deploy to the magento2.4 image
bash $(pwd)/build/podman/magento2.4/Jenkins_build_image.sh

# here we are going to setup the magento2.4 app container
bash Jenkins_setup_container.sh

# run the whole stack in the container
bash podman_run.sh