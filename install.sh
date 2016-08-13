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

    apt-get install python-pip, python-setuptool, python-wheel

    if [ -e  ${INIT_FILE} ];then
        mv ${INIT_FILE} ${INIT_FILE}".bak"
    fi
    cp ./Supervisor/supervisord ${INIT_FILE}
    chmod a+x ${INIT_FILE}
    echo "Copy the ${INIT_FILE}"

    if [ ! -d ${CONFIG_DIR} ];then
        mkdir ${CONFIG_DIR}
        echo "Create the ${CONFIG_DIR}"
    fi

    if [ -e ${CONFIG_FILE} ];then
        mv ${CONFIG_FILE} ${CONFIG_FILE}".bak"
    fi
    cp ./Supervisor/supervisord.conf ${CONFIG_FILE}
    echo "Copy the ${CONFIG_FILE}"

    if [ ! -d ${LOG_DIR} ];then
        mkdir ${LOG_DIR}
    fi

    ${INIT_FILE} start && ${INIT_FILE} status

    return $?
}

function install_shadowsocks() {
    # check the pip
    PIP=`which pip`
    if [ ! -x ${PIP} ];then
        install_supervisor
        if [ $? != 0 ];then
            exit $?
        fi
    fi

    # create the shadowsocks user
    SHADOWSOCKS_USER=`awk 'BEGIN{FS=":"}{print $1}' /etc/passwd | egrep '^shadowsocks$'`
    if [ "${SHADOWSOCKS_USER}" == '' ];then
        SHADOWSOCKS_USER='shadowsocks'
        useradd ${SHADOWSOCKS_USER}
        echo "Create the user ${SHADOWSOCKS_USER}"
    fi

    # make log dir
    LOG_DIR="/var/log/shadowsocks/"
    if [ ! -d ${LOG_DIR} ];then
        mkdir -p ${LOG_DIR}
        echo "Make the dir ${LOG_DIR}"
    fi

    # install shadowsocks
    SSSERVER=`which ssserver`
    if [ ! -x ${SSSERVER} ];then
        pip install shadowsocks
        echo "Install the shadowsocks"
    fi

    # config the shadowsocks
}


case "$1" in
    supervisor)
        install_supervisor && exit 0
        echo "supervisor install failed"
        ;;
    shadowsocks)
        install_shadowsocks && exit 0
        echo "shadowsocks install failed"
        ;;
    *)
        echo "Usage: $0 {supervisor|shadowsocks}"
        ;;
esac
