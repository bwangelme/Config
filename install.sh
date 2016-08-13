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
    CONFIG_DIR="/etc/supervisor"
    LOG_DIR="/var/log/supervisord/"

    PIP=`which pip`
    if [ ! -x ${PIP} ];then
        apt-get install python-pip
    fi

    WHEEL=`dpkg -l | grep 'python-wheel'`
    if [ "${WHEEL}" == '' ];then
        apt-get install python-wheel
    fi
    apt-get install python-setuptools, python-wheel

    if [ -e  ${INIT_FILE} ];then
        mv ${INIT_FILE} ${INIT_FILE}".bak"
    fi
    cp ./Supervisor/supervisord ${INIT_FILE}
    chmod a+x ${INIT_FILE}
    echo "Copy the ${INIT_FILE}"

    if [ ! -d ${CONFIG_DIR} ];then
        cp -r ./Supervisor/supervisor /etc/
    else
        mv ${CONFIG_DIR} ${CONFIG_DIR}".bak"
        cp -r ./Supervisor/supervisor /etc/
    fi
    echo "Copy the ${CONFIG_DIR}"

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
        chown shadowsocks:shadowsocks ${LOG_DIR}
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
