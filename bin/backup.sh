#!/bin/bash
#此文件针对所有配置文件拷贝(可配合upocfix.sh脚本完成oc升级后的配置文件复原)
back_path=/var/pbx/backup`date +%Y%m%d`/
conf_path=/etc/pbx
function log_info() {
    echo -e "\033[36m [INFO] $@ \033[0m"
}
log_info "建立备份文件夹:$back_path"
mkdir $back_path -p
log_info "拷贝所有配置文件至$back_path"
cp $conf_path/* $back_path/ -rp

