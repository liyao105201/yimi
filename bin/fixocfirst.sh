#!/bin/bash
#此脚本针对oc初次安装的部分配置项的修改,针对ali(后期出现的现场都是ali asr和tts)
script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
cd $EMICHOME
oc_config=/etc/pbx/outcall_server/callingrobot.config

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
}

function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
}

function log_warn() {
    echo -e "\033[33m [WARN] $@ \033[0m"
}
   cat << EOF
+-------------------------------------------------+
                 oc配置文件修改
+-------------------------------------------------+
EOF
sleep 3
log_info "修改webmanager_listen_port端口"
log_info "sed -i 's!<string name="webmanager_listen_port">[0-9]*<.*!<string name="webmanager_listen_port">9009</string>!' $oc_config"
sed -i 's!<string name="webmanager_listen_port">[0-9]*<.*!<string name="webmanager_listen_port">9009</string>!' $oc_config
log_info "修改oc:ip端口"
log_info "sed -i 's!<string name="oc_ip">[[:print:]]*</string!<string name="oc_ip">127.0.0.1:9009</string!' $oc_config"
sed -i 's!<string name="oc_ip">[[:print:]]*</string!<string name="oc_ip">127.0.0.1:9009</string!' $oc_config
log_info "修改ali默认tts地址"
log_info "sed -i 's!<string name="ali_tts_server_url">[[:print:]]*</string>!<string name="ali_tts_server_url">http://tts.emic:8101/stream/v1/tts</string>!' $oc_config"
sed -i 's!<string name="ali_tts_server_url">[[:print:]]*</string>!<string name="ali_tts_server_url">http://tts.emic:8101/stream/v1/tts</string>!' $oc_config
log_info "修改ali默认key id"
log_info "sed -i 's!<string name="ali_tts_appkey">[[:print:]]*</string>!<string name="ali_tts_appkey">default</string>!' $oc_config"
sed -i 's!<string name="ali_tts_appkey">[[:print:]]*</string>!<string name="ali_tts_appkey">default</string>!' $oc_config
log_info "sed -i 's!<string name="ali_tts_key_secret">[[:print:]]*</string>!<string name="ali_tts_key_secret"></string>!' $oc_config"
sed -i 's!<string name="ali_tts_key_secret">[[:print:]]*</string>!<string name="ali_tts_key_secret"></string>!' $oc_config
log_info "sed -i 's!<string name="ali_tts_access_key_id">[[:print:]]*</string>!<string name="ali_tts_access_key_id"></string>!' $oc_config"
sed -i 's!<string name="ali_tts_access_key_id">[[:print:]]*</string>!<string name="ali_tts_access_key_id"></string>!' $oc_config
log_info "sed -i 's!<string name="tts_cache_server_start">0</string>!<string name="tts_cache_server_start">1</string>!'  $oc_config"
sed -i 's!<string name="tts_cache_server_start">0</string>!<string name="tts_cache_server_start">1</string>!'  $oc_config
log_info "请按现场tts数量修改配置文件limit_QPS值,并根据机器人数量修改tts_clue_list_size值,按机器人2倍填写"
