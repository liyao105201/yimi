#!/bin/bash

crontab_file=$1

#检查crontab文件是否存在，不存在则退出
if [[ ! -f ${crontab_file} ]]
	then
		echo "crontab file ${crontab_file} not exist,exit shell"
		exit 
fi

#配置crontab文件
echo "exec crontab $crontab_file"
chmod 777 ${crontab_file}

if [[ `whoami` = 'root' ]];then
    crontab ${crontab_file}
else
    echo "the user[`whoami`] is not support!"
fi

