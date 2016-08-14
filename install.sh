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

    if ! command -v pip > /dev/null 2>&1;then
        apt-get install python-pip
    fi

    WHEEL=`dpkg -l | grep 'python-wheel'`
    if [ "${WHEEL}" == '' ];then
        apt-get install python-wheel
    fi
    SETUPTOOLS=`dpkg -l | grep 'python-setuptools'`
    if [ "${SETUPTOOLS}" == '' ];then
        apt-get install python-setuptools
    fi

    if [ -e  ${INIT_FILE} ];then
        mv ${INIT_FILE} /tmp/
        echo "Move the original ${INIT_FILE} to the /tmp"
    fi
    cp ./Supervisor/supervisord ${INIT_FILE}
    chmod a+x ${INIT_FILE}
    echo "Copy the ${INIT_FILE}"

    if [ ! -d ${CONFIG_DIR} ];then
        cp -r ./Supervisor/supervisor /etc/
    else
        if [ -d "/tmp/supervisor/" ];then
            rm -rf /tmp/supervisor
            echo "Delete the /tmp/supervisor"
        fi
        mv ${CONFIG_DIR} /tmp/
        echo "Move the original ${CONFIG_DIR} to the /tmp"
        cp -r ./Supervisor/supervisor /etc/
    fi
    echo "Copy the ${CONFIG_DIR}"

    if [ ! -d ${LOG_DIR} ];then
        mkdir ${LOG_DIR}
    fi

    echo "Please run the |${INIT_FILE} start| to start the Supervisor"

    return $?
}

function install_shadowsocks() {
    # install the supervisor
    install_supervisor

    if [ $# == 1 -a $1 == 'client' ];then
        # install shadowsocks client
        if ! command -v sslocal 2>&1 > /dev/null;then
            pip install shadowsocks
        fi
        cp ./ShadowSocks/shadowsocks.json /etc/shadowsocks.json
        echo "Copy the shadowsock client configure file"
        echo "Shadowsocks client already installed, Please change the configure file" && exit 0
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
    if ! command -v ssserver > /dev/null 2>&1;then
        pip install shadowsocks
        echo "Install the shadowsocks"
    fi

    # config the shadowsocks
    ln -s /etc/supervisor/tasks-available/shadowsocks.ini /etc/supervisor/tasks-enabled/
    echo "Link the shadowsocks configure file"

    CONFIG_FILE="/etc/shadowsocks_server.json"
    if [ -e ${CONFIG_FILE} ];then
        mv ${CONFIG_FILE} /tmp
        echo "Move the original ${CONFIG_FILE} to the /tmp"
    fi
    cp ./ShadowSocks/shadowsocks_server.json ${CONFIG_FILE}
    chmod 644 ${CONFIG_FILE}

    # change the password
    echo "Please change the password in the ${CONFIG_FILE} and restart the shadowsocks"
}


case "$1" in
    supervisor)
        install_supervisor && exit 0
        echo "supervisor install failed"
        ;;
    shadowsocks)
        if [ $# == 2 ];then
            install_shadowsocks $2 && exit 0
            echo "shadowsocks client install failed"
        fi
        install_shadowsocks && exit 0
        echo "shadowsocks install failed"
        ;;
    *)
        echo "Usage: $0 {supervisor|shadowsocks}"
        ;;
esac
