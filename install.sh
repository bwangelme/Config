#!/bin/bash
#History:
#   Michael	Aug,13,2016
#Program:
#


if [ $UID != 0 ];then
    echo "You must run this script as root"
    exit 0
fi


function install_supervisor() {
    INIT_FILE="/etc/init.d/supervisord"
    CONFIG_DIR="/etc/supervisor/"
    CONFIG_FILE=${CONFIG_DIR}"supervisord.conf"
    LOG_DIR="/var/log/supervisord/"

    if [ -e  ${INIT_FILE} ];then
        mv ${INIT_FILE} ${INIT_FILE}".bak"
    fi
    cp ./Supervisor/supervisord ${INIT_FILE}
    chmod a+x ${INIT_FILE}

    if [ ! -d ${CONFIG_DIR} ];then
        mkdir ${CONFIG_DIR}
    fi

    if [ -e ${CONFIG_FILE}];then
        mv ${CONFIG_FILE} ${CONFIG_FILE}".bak"
    fi
    cp ./Supervisor/supervisord.conf ${CONFIG_FILE}

    if [ -d ${LOG_DIR}];then
        mkdir ${LOG_DIR}
    fi

    ${INIT_FILE} start && ${INIT_FILE} status

    return $?
}


case "$1" in
    supervisor)
        install_supervisor && exit 0
        echo "supervisor install failed"
        ;;
    *)
        echo "Usage: $0 {supervisor}"
        ;;
esac
