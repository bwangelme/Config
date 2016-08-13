我的配置项
==========


## 安装

可通过`./install.sh`来安装配置问，目前仅支持`Supervisor`和`ShadowSocks`

此安装脚本基于Ubuntu 16.04构建，在其他版本Linux上并不适用。

## TODO

+ supervisord的启动脚本`./Supervisor/supervisord`仍然存在一些问题。

   + PID文件丢失以后，无法`kill`掉
