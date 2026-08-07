#!/bin/bash
#此脚本针对容器内部tar包替换升级
#将脚本放到服务器，先执行以下步骤
path=/home/emi
file=outcallserver.tar.gz
config=conf/callingrobot.config
conf_file=callingrobot.config
configbak=conf/callingrobot.config_bak

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"

}

function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"

}
supervisorctl status|grep ttscache_server
if [[ $? -eq 0 ]];then
   supervisorctl stop ttscache_server
   else
   log_info "该oc未开启ttscache_server服务"
fi
supervisorctl stop outcall_server
log_info "关闭oc服务"

if [[ -f ${path}/${file} ]];then
   log_info "oc_tar包存在准备oc升级"
   else
   log_error "未找到升级tar包"
fi
cd ${path}
mv outcallserver outcallserver_`date +%Y%m%d` -f
cp -rp ${path}/outcallserver/${config} $path/outcallserver_`date +%Y%m%d`/
tar -zxvf ${file} -C ${path}
cd ${path}/outcallserver
mv ${config} ${configbak}
cd ${path}
cp outcallserver_`date +%Y%m%d`/$conf_file ${path}/outcallserver/conf -rp
supervisorctl start outcall_server
status_oc=`supervisorctl status|grep outcall_server|awk -F '[ ]*' '{print $2}'|tr -d '\r\n'`
sleep 5
if [[ "${status_oc}" == "RUNNING" ]];then
   log_info "oc启动成功"
   else
   log_error "请人为检查oc服务状态"

fi
supervisorctl status|grep ttscache_server
if [[ $? -eq 0 ]];then
   supervisorctl start ttscache_server
   sleep 5
   status_tts=`supervisorctl status|grep ttscache_server|awk -F '[ ]*' '{print $2}'|tr -d '\r\n'`
   if [[ "${status_tts}" == "RUNNING" ]];then
      log_info "ttscache_server启动成功"
   else
      log_error "请人为检查ttscache_server服务状态"
   fi
fi

