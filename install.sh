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
    if [[ -x $(which supervisord) ]];then
        return 0
    fi

    SYSTEMD_FILE="/etc/systemd/system/supervisord.service"
    CONFIG_DIR="/etc/supervisor"
    LOG_DIR="/var/log/supervisord/"

    if [[ ! -x $(which pip) ]];then
        apt-get -y install python-pip
    fi

    if [[ ! -x $(which supervisord) ]];then
        pip install supervisor
    fi

    WHEEL=`dpkg -l | grep 'python-wheel'`
    if [ "${WHEEL}" == '' ];then
        apt-get -y install python-wheel
    fi
    SETUPTOOLS=`dpkg -l | grep 'python-setuptools'`
    if [ "${SETUPTOOLS}" == '' ];then
        apt-get -y install python-setuptools
    fi

    if [[ -e ${SYSTEMD_FILE} ]];then
        mv ${SYSTEMD_FILE} /tmp/
        echo "Move the original ${SYSTEMD_FILE} to the /tmp"
    fi
    cp ./Supervisor/supervisord.service ${SYSTEMD_FILE}
    chmod a+x ${SYSTEMD_FILE}
    echo "Copy the ${SYSTEMD_FILE}"
    systemctl daemon-reload
    systemctl enable supervisord

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

    echo "Please run the |sudo systemctl start supervisord| to start the Supervisor"

    return $?
}

function install_shadowsocks() {
    # install the supervisor
    install_supervisor

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
    if [[ ! -x $(which ssserver) ]];then
        pip install shadowsocks
        echo "Install the shadowsocks"
    fi

    if [ "$#" == 1 -a "$1" == 'client' ];then
        # install shadowsocks client
        if [[ ! -x $(which sslocal) ]];then
            pip install shadowsocks
        fi

        # config the sslocal
        cp ./ShadowSocks/shadowsocks.json /etc/shadowsocks.json
        echo "Copy the shadowsock client configure file"
        ln -s /etc/supervisor/tasks-available/sslocal.ini /etc/supervisor/tasks-enabled/
        echo "Link the Shadowsocks client supervisor configure file"

        echo "Shadowsocks client already installed, Please change the configure file" && exit 0
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

function install_git() {
    if [[ ! -x $(which git) ]];then
        apt-get -y install git
    fi
    if [[ -e "/etc/gitconfig" ]];then
        mv "/etc/gitconfig" "/etc/gitconfig.bak"
    fi
    ln -s "$(pwd)/Git/gitconfig" /etc/gitconfig
}

function install_blog() {
    install_supervisor

    REPO_DIR="/var/www/blog"
    if [[ ! -d ${REPO_DIR} ]];then
        git clone -b master https://github.com/bwangel23/bwangel23.github.io.git ${REPO_DIR}
    else
        git -C ${REPO_DIR} pull origin master
    fi

    systemctl restart supervisord.service

    AVALIABLE_FILE="/etc/nginx/sites-available/blog.conf"
    ENABLE_FILE="/etc/nginx/sites-enabled/blog.conf"
    if [[ ! -x $(which nginx) ]];then
        sudo apt-get -y install nginx
    fi
    if [[ -e "${ENABLE_FILE}" ]];then
        rm ${ENABLE_FILE} && echo "Delete the ${ENABLE_FILE}"
    fi
    if [[ -e "${AVALIABLE_FILE}" ]];then
        rm ${AVALIABLE_FILE} && echo "Delete the ${AVALIABLE_FILE}"
    fi
    cp "$(pwd)/Blog/blog.conf" ${AVALIABLE_FILE}
    ln -s ${AVALIABLE_FILE} ${ENABLE_FILE}
    nginx -s reload 2> /dev/null || nginx
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
    shadowsocks-client)
        install_shadowsocks "client" && exit 0
        echo "shadowsocks client install failed"
        ;;
    git)
        install_git && echo "Link the gitconfig"
        ;;
    blog)
        install_blog && echo "Install the hexo blog"
        ;;
    *)
        echo "Usage: $0 {supervisor|shadowsocks|shadowsocks-client|git|blog}"
        ;;
esac
