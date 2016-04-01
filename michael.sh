#将CapsLock映射成Esc键
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'

# 翻墙配置
alias gfw='sudo sslocal -c /etc/shadowsocks.json --log-file /var/log/shadowsocks.log'

# virtualenv wrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh
