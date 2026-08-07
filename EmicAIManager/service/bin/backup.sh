#!/bin/bash
#此文件针对所有配置文件拷贝
back_path=/var/pbx/backup`date +%Y%m%d`/
conf_path=/etc/pbx
function log_info() {
    echo -e "\033[36m [INFO] $@ \033[0m"
}
log_info "建立备份文件夹:$back_path"
mkdir $back_path -p
log_info "拷贝所有配置文件至$back_path"
cp $conf_path/* $back_path/ -rp
log_info "oc程序升级后执行同路径下的upocfix.sh实现配置文件的相应项修改"