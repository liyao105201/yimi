#!/bin/bash
log=/var/pbx/logs/restartoc_sh.logs
rm $log -f
echo "日期：`date`"
date >>$log
restartoc() {
 docker restart outcallserver >>/dev/null
 sleep 50
}
echo "脚本正在运行，请勿关闭"
restartoc
if [[ $? -ne 0 ]];then
   echo "oc重启失败，接着重启" >>$log
   restartoc
else
   echo "oc重启成功">>$log
fi
echo "脚本正在运行，请勿关闭"
sleep 50
status_oc=`docker exec -it outcallserver supervisorctl status|awk '/outcall_server/{print $2}' |tr -d '\r\n\t'|tr [a-z] [A-Z]`
echo "oc重启后状态，$status_oc" >>$log
status_tts=`docker exec -it outcallserver supervisorctl status|awk '/ttscache_server/{print $2}' |tr -d '\r\n\t'|tr [a-z] [A-Z]`
echo "tts重启后状态，$status_tts" >>$log

if [[ "${status_oc}" == "RUNNING" ]]&&[[ "${status_tts}" == "RUNNING"  ]];then
     echo "8848端口状态" >>$log
     netstat -an|grep 8848 >>$log
   if [[ $? -ne 0 ]];then
      echo "8848端口未打开" >>$log
      echo "重启oc" >>$log
      restartoc >>/dev/null
	  echo "脚本正在运行，请勿关闭"
      sleep 10
   else 
      echo "8848端口打开" >>$log
   fi
     echo "9009端口状态" >>$log
     netstat -an|grep 9009 >>$log
   if [[ $? -ne 0 ]];then
      echo "9009端口未打开" >>$log
      echo "重启oc" >>$log
      restartoc >>/dev/null
	  echo "脚本正在运行，请勿关闭"
      sleep 10
   else
      echo "9009端口打开" >>$log
   fi 
fi
echo "脚本执行完毕" >>$log
