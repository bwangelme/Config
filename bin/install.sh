#!/bin/bash
#
# Author: bwangel<bwangel.me@gmail.com>
# Date: Apr,08,2017 14:35

function install_bin () {
    if [[ ! -d "$HOME/bin" ]];then
        mkdir $HOME/bin
    fi
    for bin in $(ls "$(pwd)/bin");do
        if [[ $bin != "install.sh" ]];then
            cp -v "$(pwd)/bin/$bin" $HOME/bin/
        fi
    done
}

install_bin && exit 0
echo "bin files install failed"
