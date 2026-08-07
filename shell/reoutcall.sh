#!/bin/bash
#该脚本应对不同生产环境oc配置替换
tarhome=/home/emi
config=conf/callingrobot.config
configbak=conf/callingrobot.config_bak
outcallbak=/home/emi/outcallserver_`date +%Y%m%d`
file=outcallserver.tar.gz
#webmanager_listen_port=9010
conf_callingrobot=callingrobot.config
tts_path=/home/tts_cached
ai_addr=https://ai.emic.com.cn
db_ip=172.17.214.23
oc1=172.17.214.20
#oc1=192.168.1.159
oc2=172.17.214.30
oc3=172.17.214.42
oc4=172.17.214.45
oc5=172.17.214.50
oc6=172.17.253.82
oc7=172.17.214.65
fs1=172.17.214.22
fs2=172.17.214.31
fs3=172.17.214.43  
fs4=172.17.214.44
fs5=172.17.214.49
fs6=172.17.253.81
fs7=172.17.214.64
redis_port=6379
ipaddr=`ifconfig|grep inet|awk '{print $2}'|grep '172\.17\.214'`
#ipaddr=`ifconfig|grep inet|awk '{print $2}'|grep '192\.168\.1'`
function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
}
function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
}
function upocbeforedo(){
   if [[ -f ${tarhome}/${file} ]];then
      log_info "oc_tar包存在准备oc升级"
   else
      log_error "未找到升级tar包"
   fi
   supervisorctl stop outcall_server
   log_info "关闭oc服务"
   cd ${tarhome}
   mv outcallserver outcallserver_`date +%Y%m%d`
   echo "原outcallserver备份成outcallserver_`date +%Y%m%d`"
   log_info "开始解压新版本oc包"
   tar -zxvf ${file} -C ${tarhome}
   # cd /home/emi/outcallserver/conf;cp -rp callingrobot.config /home/emi/outcallserver_`date +%Y%m%d`
   # echo "callingrobot.config已备份至outcallserver_`date +%Y%m%d`"
   cat << EOF
+-------------------------------------------------+
             
             outcallserver.tar.gz 解压ok

+-------------------------------------------------+
EOF
  cd ${tarhome}/outcallserver
  log_info "压缩包原始conf文件备份至${configbak}"
  yes|cp ${config} ${configbak} -rpf
}
function ipchoose(){
  case "$ipaddr" in
      "$oc1")
      change_config $oc1 $fs1
      ;;
      "$oc2")
      change_config $oc2 $fs2
      ;;
      "$oc3")
      change_config $oc3 $fs3
      ;;
      "$oc4")
      change_config $oc4 $fs4
      ;;
      "$oc5")
      change_config $oc5 $fs5
      ;;
      "$oc6")
      change_config $oc6 $fs6
      ;;
      "$oc7")
      change_config $oc7 $fs7
      ;;
      *)
      echo "No OC IPADDR"
      exit 1
      ;;
  esac
}
function change_config(){
   cd $tarhome/outcallserver/conf
   if [[ "$1" != "$oc3" ]]&&[[ "$1" != "$oc4" ]]&&[[ "$1" != "$oc5" ]]&&[[ "$1" != "$oc7" ]];then
      log_info "sed -i 's!<string name="webmanager_listen_port">[[:print:]]*</string>!<string name="webmanager_listen_port">9010</string>!'  $conf_callingrobot"
      sed -i  's!<string name="webmanager_listen_port">[[:print:]]*</string>!<string name="webmanager_listen_port">9010</string>!'  $conf_callingrobot
      log_info "sed -i 's!<string name="oc_ip">[[:print:]]*</string>!<string name="oc_ip">'$1':9010</string>!' $conf_callingrobot"
      sed -i 's!<string name="oc_ip">[[:print:]]*</string>!<string name="oc_ip">'$1':9010</string>!' $conf_callingrobot
   else
      log_info "sed -i  's!<string name="webmanager_listen_port">[[:print:]]*</string>!<string name="webmanager_listen_port">9009</string>!'  $conf_callingrobot"
      sed -i  's!<string name="webmanager_listen_port">[[:print:]]*</string>!<string name="webmanager_listen_port">9009</string>!'  $conf_callingrobot
      log_info "sed -i 's!<string name="oc_ip">[[:print:]]*</string>!<string name="oc_ip">'$1':9009</string>!' $conf_callingrobot"
      sed -i 's!<string name="oc_ip">[[:print:]]*</string>!<string name="oc_ip">'$1':9009</string>!' $conf_callingrobot
   fi
   webmanager_listen_port_now=`cat callingrobot.config |grep 'webmanager_listen'|tr -cd '[0-9]'`
   log_info "$ipaddr端口：$webmanager_listen_port_now"
   log_info "sed -i 's!<int name="task_pool_size">[[:print:]]*!<int name="task_pool_size">400</int>!' $conf_callingrobot"
   sed -i 's!<int name="task_pool_size">[[:print:]]*!<int name="task_pool_size">400</int>!' $conf_callingrobot
   log_info "sed -i 's!<int name="thread_pool_size">[[:print:]]*!<int name="thread_pool_size">20</int>!' $conf_callingrobot"
   sed -i 's!<int name="thread_pool_size">[[:print:]]*!<int name="thread_pool_size">20</int>!' $conf_callingrobot
   log_info "sed -i 's!<string name="redis_pw">[[:print:]]*</string>!<string name="redis_pw">greedisgood</string>!' $conf_callingrobot"
   sed -i 's!<string name="redis_pw">[[:print:]]*</string>!<string name="redis_pw">greedisgood</string>!' $conf_callingrobot
   log_info "sed -i 's!<string name="redis_ip">[[:print:]]*</string>!<string name="redis_ip">'$oc1'</string>!' $conf_callingrobot"
   sed -i 's!<string name="redis_ip">[[:print:]]*</string>!<string name="redis_ip">'$oc1'</string>!' $conf_callingrobot
   log_info "sed 's!<int name="redis_port">[[:print:]]*</int>!<int name="redis_port">'$redis_port'</int>!'  $conf_callingrobot"
   sed -i 's!<int name="redis_port">[[:print:]]*</int>!<int name="redis_port">'$redis_port'</int>!'  $conf_callingrobot
   log_info "sed -i 's!<string name="experience_script_ids">[[:print:]]*</string>!<string name="experience_script_ids">101069,100846,100850,100474</string>!' $conf_callingrobot"
   sed -i 's!<string name="experience_script_ids">[[:print:]]*</string>!<string name="experience_script_ids">101069,100846,100850,100474</string>!' $conf_callingrobot
   log_info "sed -i 's!<string name="freeswitch_address">[[:print:]]*</string>!<string name="freeswitch_address">'$2'</string>!' $conf_callingrobot"
   sed -i 's!<string name="freeswitch_address">[[:print:]]*</string>!<string name="freeswitch_address">'$2'</string>!' $conf_callingrobot
   if [[ "$1" == "$oc1" ]];then
      log_info "sed -i 's!<string name="freeswitch_inbound_pwd">[[:print:]]*</string>!<string name="freeswitch_inbound_pwd">Emicnet2019</string>!' $conf_callingrobot"
      sed -i 's!<string name="freeswitch_inbound_pwd">[[:print:]]*</string>!<string name="freeswitch_inbound_pwd">Emicnet2019</string>!' $conf_callingrobot
      log_info "sed -i 's!<string name="tts_cache_server_clue_threads_num">[[:print:]]*!<string name="tts_cache_server_clue_threads_num">20</string>!' $conf_callingrobot"
      sed -i 's!<string name="tts_cache_server_clue_threads_num">[[:print:]]*!<string name="tts_cache_server_clue_threads_num">20</string>!' $conf_callingrobot
   fi
   log_info "sed 's!<string name="tts_cache_server_ip">[[:print:]]*!<string name="tts_cache_server_ip">'$oc1'</string>!'  $conf_callingrobot"
   sed -i 's!<string name="tts_cache_server_ip">[[:print:]]*!<string name="tts_cache_server_ip">'$oc1'</string>!'  $conf_callingrobot
   log_info "sed -i 's!<string name="tts_cached_file_localpath">[[:print:]]*</string>!<string name="tts_cached_file_localpath">'$tts_path'</string>!' $conf_callingrobot"
   sed -i 's!<string name="tts_cached_file_localpath">[[:print:]]*</string>!<string name="tts_cached_file_localpath">'$tts_path'</string>!' $conf_callingrobot
   log_info "sed -i 's!<string name="tts_clue_list_size">[[:print:]]*</string>!<string name="tts_clue_list_size">1024</string>!' $conf_callingrobot"
   sed -i 's!<string name="tts_clue_list_size">[[:print:]]*</string>!<string name="tts_clue_list_size">1024</string>!' $conf_callingrobot
   log_info "sed -i 's!<string name="Alitts_limit_QPS">[[:print:]]*</string>!<string name="Alitts_limit_QPS">150</string>!' $conf_callingrobot"
   sed -i 's!<string name="Alitts_limit_QPS">[[:print:]]*</string>!<string name="Alitts_limit_QPS">150</string>!' $conf_callingrobot
   log_info "sed -i 's!<string name="DBtts_limit_QPS">[[:print:]]*</string>!<string name="DBtts_limit_QPS">30</string>!' $conf_callingrobot"
   sed -i 's!<string name="DBtts_limit_QPS">[[:print:]]*</string>!<string name="DBtts_limit_QPS">30</string>!' $conf_callingrobot
   log_info "sed -i 's!<string name="upper_bound_score">[[:print:]]*</string>!<string name="upper_bound_score">1.0</string>!' $conf_callingrobot"
   sed -i 's!<string name="upper_bound_score">[[:print:]]*</string>!<string name="upper_bound_score">1.0</string>!' $conf_callingrobot
   log_info "sed -i 's!<string name="web_api_host">[[:print:]]*</string>!<string name="web_api_host">'$ai_addr'</string>!' $conf_callingrobot"
   sed -i 's!<string name="web_api_host">[[:print:]]*</string>!<string name="web_api_host">'$ai_addr'</string>!' $conf_callingrobot
   log_info "sed -i 's!<bool name="send_tr_when_transfer">[[:print:]]*</bool>!<bool name="send_tr_when_transfer">true</bool>!' $conf_callingrobot"
   sed -i 's!<bool name="send_tr_when_transfer">[[:print:]]*</bool>!<bool name="send_tr_when_transfer">true</bool>!' $conf_callingrobot
   log_info "sed 's!^[ ]*<string name="db_conn_str">host=[[:print:]]*!    <string name="db_conn_str">host='$db_ip';port=3306;db=ai;user=emi_ai;password=Sinicnet123456;compress=true;auto-reconnect=true</string>!' $conf_callingrobot"
   sed -i 's!^[ ]*<string name="db_conn_str">host=[[:print:]]*!    <string name="db_conn_str">host='$db_ip';port=3306;db=ai;user=emi_ai;password=Sinicnet123456;compress=true;auto-reconnect=true</string>!' $conf_callingrobot
}
function upocafterdo(){
   supervisorctl start outcall_server
   sleep 10
   status_oc=`supervisorctl status|grep outcall_server|awk -F '[ ]*' '{print $2}'|tr -d '\r\n'`
   if [[ "${status_oc}" == "RUNNING" ]];then
      log_info "oc启动成功"
      else
      log_error "请人为检查oc服务状态"
   fi
}
function main(){
   upocbeforedo
   ipchoose
   upocafterdo
}
main
