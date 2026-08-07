#!/bin/bash
service crond start
#添加定时任务
crontab -l|grep freecheck
if [[ $? -ne 0 ]];then
   echo "0 1,3,5,7 * * * /etc/pbx/scripts/freecheck.sh">/dev/null >> /var/spool/cron/root
fi
#判断内存是否大于70	
usefree=`free -m|grep Mem|awk '{print $3}'|tr -d '\r\n'`
allfree=`free -m|grep Mem|awk '{print $2}'|tr -d '\r\n'`
per=$[$usefree*100/$allfree]
if [[ $per -gt 70 ]];then
    docker ps|grep freeswitch
    if [[ $? -eq 0 ]];then
    docker exec -it freeswitch supervisorctl restart freeswitch 
    else
       sudo su
       supervisorctl restart freeswitch
       ps -ef|grep freeswitch|grep -v grep
       if [[ $? -ne 0 ]];then
       pid=`ps -ef|grep freeswitch|grep -v grep|awk '{print $2}'`
       kill -9 $pid
       fi
    fi
fi