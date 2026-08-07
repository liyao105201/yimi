#!/bin/bash
file=/var/pbx/ly_temp/ly.txt
cat <<EOF
+++++++++++++++++++++++++
   输出百分比大于30的磁盘
+++++++++++++++++++++++++
EOF
temp=`df -h|awk 'NR>1{print $1,$5}'|awk '{print $2}'`
for percnet in $temp
do
   a=${percnet%%%}
   if [[ $a -gt 30 ]];then  
      sed -n '/'$percnet'/p' $file 
   fi
done


SELECT account.gameuid AS account_gameuid, account.nickname AS account_nickname
FROM account INNER JOIN bind ON bind.fromid = account.gameuid
WHERE bind.toid = %(toid_1)s