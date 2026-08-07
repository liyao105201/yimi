#!/bin/bash
#测试系统脚本
docker rm emic-ai-mysql -f
rm  /var/pbx/lib/emic_mysql/mysql_5.7.40 -rf
rm /etc/pbx/emic_mysql/mysql_5.7.40 -rf