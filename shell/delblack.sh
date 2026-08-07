#!/bin/bash
user=root
password=Sinicnet@123456
ly_temp=black_add.txt
db=ai
mysql -u$user -p$password  $db -ss -e 'SELECT phone FROM aicall_high_risk_customer where black_add=1;' > $ly_temp
echo "正在连接数据库"
sleep 3
echo "mysql -u$user -p$password  $db -ss -e 'SELECT phone FROM aicall_high_risk_customer where black_add=1;'"
while read line
do
  echo "要删除的号码 $line"
  echo "delete from aicall_global_blacklist where  mobile =$line;" >> delete.sql
done<$ly_temp
echo "sql补充完整，执行delete.sql"
mysql -u$user -p$password  $db -ss -e 'source delete.sql;'
echo "脚本执行完毕"