#!/bin/bash
#!需先执行完毕backup.sh脚本完成对配置的备份
#此文件针对oc升级后的配置恢复(私有化)
path=/var/pbx/backup`date +%Y%m%d`/outcall_server
conf_bak=/var/pbx/backup`date +%Y%m%d`
conf_oc=/etc/pbx/outcall_server
conf_file=callingrobot.config
conf_file_bak=callingrobot.config_bak
yimi_temp=detail_diff.txt
db_conf='<string name="db_conn_str">host=mysql.emic;port=13306;db=ai;user=emi_ai;password=Sinicnet@123456;compress=true;auto-reconnect=true</string>'
function log_info() {
    echo -e "\033[36m [INFO] $@ \033[0m"
}
startoc() {
 docker start outcallserver >>/dev/null
 sleep 10
}
restartoc() {
 docker start outcallserver >>/dev/null
 sleep 10
}
stopoc(){
  docker stop outcallserver >>/dev/null
  sleep 2
}
cat << EOF
+-------------------------------------------------+
    "正在备份配置文件"
    "配置文件备份路径:$conf_bak"
+-------------------------------------------------+
EOF
#先关闭程序否则修改时会出现某些问题
stopoc
cd $path
if [[ -f $conf_file_bak ]];then
   rm $conf_file_bak -f
fi
cd $conf_oc
if [[ -f $conf_file_bak ]];then
   rm $conf_file_bak -f
fi
mv $path/$conf_file $path/$conf_file_bak 
cp $path/$conf_file_bak $conf_oc/ -p
cd $conf_oc
diff -w $conf_file_bak $conf_file  |grep '^<'|awk -F '=' '{print $2}'|awk -F '>'  '{print $1}'>$yimi_temp
sed -i '/^$/d' $yimi_temp
sed -i '/db_conn_str/d'  $yimi_temp
while read line
do
  detail=`cat $conf_file_bak|grep $line`
  log_info "原始配置文件配置为:$detail"
  num=`cat $conf_file |grep -n "$line"|awk -F ":" '{print $1}'`
  log_info "正在修改配置文件的$num行---------,请稍等"
  res=`grep $line $conf_file|grep '<!'`
  if [[ $res == '' ]];then
      sed -i "${num}c${detail}" $conf_file
      sed -r -i "${num}s/^/    /" $conf_file
  fi
done<$yimi_temp
cat $conf_file|grep -n 'db_conn'|awk '/--/'|awk -F : '{print $1}'>drop_db.txt
cat $conf_file|grep -n 'db_conn'|awk -F : '{print $1}'>all_db.txt
for a in `cat drop_db.txt`
do
   sed -i "/${a}/d" all_db.txt
done
num=`cat all_db.txt`
sed -i "${num}c${db_conf}" $conf_file
sed -r -i "${num}s/^/    /" $conf_file
mv $path/$conf_file_bak $path/$conf_file 
#删除升级过程中产生的临时文件
rm $yimi_temp $conf_file_bak  drop_db.txt all_db.txt -f
log_info "正在重启oc程序"
startoc
sleep 5
status_oc=`docker exec -it outcallserver supervisorctl status|awk '/outcall_server/{print $2}' |tr -d '\r\n\t'|tr [a-z] [A-Z]`
echo "oc重启后状态，$status_oc" 
status_tts=`docker exec -it outcallserver supervisorctl status|awk '/ttscache_server/{print $2}' |tr -d '\r\n\t'|tr [a-z] [A-Z]`
echo "tts重启后状态，$status_tts" 
if [[ "${status_oc}" == "RUNNING" ]]&&[[ "${status_tts}" == "RUNNING"  ]];then
     log_info "8848端口状态正常" 
     netstat -an|grep 8848 
   if [[ $? -ne 0 ]];then
      log_error "8848端口未打开" 
      echo "重启oc" 
      restartoc >>/dev/null
	   echo "脚本正在运行，请勿关闭"
      sleep 10
   else 
      echo "8848端口打开" 
   fi
     echo "9009端口状态:" 
     netstat -an|grep -E "9009|9010" 
   if [[ $? -ne 0 ]];then
      echo "oc端口未打开" 
      echo "重启oc" 
      restartoc >>/dev/null
	   echo "脚本正在运行，请勿关闭"
      sleep 10
   else
      log_info "oc端口打开" 
   fi 
fi
echo "脚本执行完毕" 
