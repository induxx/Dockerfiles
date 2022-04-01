#!/bin/bash
set -e

# As cron call this shell as an interpreter (So with "-c" arg) with have to shift $1 if containing "-c"
if [ "$1" == "-c" ]; then
    COMMAND="${@:2}"
else
    COMMAND="$@"
fi

APP_DIR="/build/app"
PHP_PATH=$(which php)
PIM_BIN_CONSOLE="${APP_DIR}/bin/console"
LOG_PATH="${APP_DIR}/var/logs"
LOG_FILE_NAME=$(echo "${COMMAND}" | tr -c "[:alnum:]-\n" "_" | cut -c 1-240)
LOCK_FOLDER="/var/lock/cron"
LOCK_FILE="${LOCK_FOLDER}/${LOG_FILE_NAME}.lock"

if [ ! -d "${LOCK_FOLDER}" ]; then
    mkdir -p ${LOCK_FOLDER}
fi

run_command() {
    echo "$(date +%Y-%m-%d_%H:%M:%S) Starting: ${PHP_PATH} ${PIM_BIN_CONSOLE} ${COMMAND}" >> ${LOG_PATH}/${LOG_FILE_NAME}.log 2>&1
    ${PHP_PATH} ${PIM_BIN_CONSOLE} ${COMMAND} >> ${LOG_PATH}/${LOG_FILE_NAME}.log 2>&1
    echo "$(date +%Y-%m-%d_%H:%M:%S) Finished: ${PHP_PATH} ${PIM_BIN_CONSOLE} ${COMMAND}" >> ${LOG_PATH}/${LOG_FILE_NAME}.log 2>&1
}

cleanup() {
    state=$?
    if [ ${state} -ne 0 ]; then
        echo "An error has occured with status code : ${state}"
        if [ -f "${LOG_PATH}/${LOG_FILE_NAME}.log" ]; then
            echo "Content of log file \"${LOG_PATH}/${LOG_FILE_NAME}.log\""
            echo "-------------------------------------------------------"
            cat ${LOG_PATH}/${LOG_FILE_NAME}.log
            echo "-------------------------------------------------------"
        fi
    fi
    rm -f ${LOCK_FILE}
}

main() {
    trap cleanup EXIT
    run_command
}

locked() {
    echo "Unable to get the lock when running $0 $*."
    echo "Process already running"
    echo ""
    ps awxf
    exit 2
}

(
flock -n 9 || locked "$@"
    main
) 9> ${LOCK_FILE}
