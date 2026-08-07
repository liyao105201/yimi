#!/bin/bash
OC_CONF=/etc/pbx/outcall_server/callingrobot.config
OC_CONF_BAK=/etc/pbx/outcall_server/callingrobot.config.bak
echo "执行conf文件备份操作"
cp -rp ${OC_CONF}  ${OC_CONF_BAK}
file="/etc/pbx/outcall_server/callingrobot.config"
echo "正在修改client_secret配置"
sed -i 's!^[ ]* <string name="client_secret">[[:print:]]*</string>!    <string name="client_secret"></string>!' ${OC_CONF}
echo "正在修改client_id配置"
sed -i 's!^[ ]* <string name="client_id">[[:print:]]*</string>!    <string name="client_id"></string>!'  ${OC_CONF}
echo "正在修改tts_cache配置"
sed -i 's!^[ ]* <string name="tts_cache_server_start">0</string>!    <string name="tts_cache_server_start">1</string>!' ${OC_CONF}
echo "正在修改DBtts配置"
sed -i 's!^[ ]* <string name="DBtts_limit_QPS">[0-9]*</string>!    <string name="DBtts_limit_QPS">4</string>!' ${OC_CONF}
echo "正在修改tts_cache clean time"
sed -i 's!^[ ]* <string name="tts_cached_file_clean_time">[[:print:]]*</string>!    <string name="tts_cached_file_clean_time">22:39:30</string>!' ${OC_CONF}
docker restart outcallserver
ps -ef|grep outcall
if [[ $? -eq 0 ]];then
  echo "sh cmd success"
else
 echo  "sh cmd fail.恢复conf文件"
   cp -rp  ${OC_CONF_BAK} ${OC_CONF}  
fi