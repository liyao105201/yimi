#!/bin/bash
temp_fail_txt=/var/pbx/fail.txt
FAIL_WAIT_robot=`docker exec -it freeswitch fs_cli -H localhost -P 8011 -p Emicnet123456 -x 'sofia status'|grep FAIL_WAIT|awk -F':' '{print $3}'|awk -F " " '{print $1}'>fail.txt`
while read line
do 
   echo "注册失败机器人: $line"
   echo "正在删除容器内部文件${line}.xml"
   docker exec -t freeswitch /bin/bash -c  "cd  /etc/freeswitch/dialplan/public;rm ${line}.xml -f"
   docker exec -t freeswitch /bin/bash -c  "cd  /etc/freeswitch/sip_profiles/external;rm ${line}.xml -f"
   docker restart freeswitch
   if [[ $? -eq 0 ]];
      echo "重启fs"
   fi
done< $temp_fail_txt