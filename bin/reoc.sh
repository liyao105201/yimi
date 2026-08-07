#!/bin/bash
#此脚本针对容器内部tar包替换升级(私有化安装)
#将脚本放到服务器，先执行以下步骤
path=/home/emi
file=outcallserver.tar.gz
config=outcallserver/conf/callingrobot.config
conf_file=callingrobot.config
configbak=outcallserver/conf/callingrobot.config_bak
yimi_temp=detail_diff.txt
db_conf='<string name="db_conn_str">host=mysql.emic;port=13306;db=ai;user=emi_ai;password=Sinicnet@123456;compress=true;auto-reconnect=true</string>'

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"

}

function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"

}
supervisorctl status|grep ttscache_server
if [[ $? -eq 0 ]];then
   log_info "关闭ttscache_server服务"
   supervisorctl stop ttscache_server
   else
   log_info "该oc未开启ttscache_server服务"
fi
log_info "关闭oc服务"
supervisorctl stop outcall_server
if [[ -f ${path}/${file} ]];then
   log_info "oc_tar包存在准备oc升级"
   else
   log_error "未找到升级tar包"
fi
cd ${path}
mv outcallserver outcallserver_`date +%Y%m%d` -f
cp -rp ${path}/$config $path/outcallserver_`date +%Y%m%d`/
tar -zxvf ${file} -C ${path}
cd ${path}
cp outcallserver_`date +%Y%m%d`/$conf_file ${path}/$configbak -rp
diff -w $configbak $config  |grep '^<'|awk -F '=' '{print $2}'|awk -F '>'  '{print $1}'>$yimi_temp
sed -i '/^$/d' $yimi_temp
sed -i '/db_conn_str/d'  $yimi_temp
while read line
do
  detail=`cat $configbak|grep $line`
  log_info "原始配置文件配置为:$detail"
  num=`cat $config |grep -n "$line"|awk -F ":" '{print $1}'`
  log_info "正在修改配置文件的$num行---------,请稍等"
  res=`grep $line $config|grep '<!'`
  if [[ $res == '' ]];then
      sed -i "${num}c${detail}" $config
      sed -r -i "${num}s/^/    /" $config
  fi
done<$yimi_temp
cat $config|grep -n 'db_conn'|awk '/--/'|awk -F : '{print $1}'>drop_db.txt
cat $config|grep -n 'db_conn'|awk -F : '{print $1}'>all_db.txt
for a in `cat drop_db.txt`
do
   sed -i "/${a}/d" all_db.txt
done
num=`cat all_db.txt`
sed -i "${num}c${db_conf}" $config
sed -r -i "${num}s/^/    /" $config
rm $yimi_temp $configbak  drop_db.txt all_db.txt -f
supervisorctl start outcall_server
sleep 5
status_oc=`supervisorctl status|grep outcall_server|awk -F '[ ]*' '{print $2}'|tr -d '\r\n'`
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

