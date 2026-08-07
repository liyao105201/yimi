#!/bin/bash
back_path=/var/pbx/backup_`date +%Y%m%d`
data_path=/var/pbx/website/shell/mysql
file=$data_path/updateaicall.sql
function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
}
function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
}
if [[ !-d back_path ]];then
   log_info "建立备份文件夹:$back_path"
   mkdir -p $back_path
fi
# log_info "现版本的"
# docker cp aicall:$file $back_path
read -p "该场景是否是工行版本," input
case ${input} in
		[yY][eE][sS]|[yY])

			;;
		[nN][oO]|[nN])
	
			;;
		*)
            echo "您输入选择"
			;;
	esac



yum list installed|grep mysql
if [[ $? -eq 0]];then
   log_info "备份msyql数据库"
   log_info "mysqldump -uroot -pSinicnet@123456 ai -R -E --single-transaction >$back_path/ai_`date +%Y%m%d`.sql"
   mysqldump -uroot -pSinicnet@123456 ai -R -E --single-transaction >$back_path/ai_`date +%Y%m%d`.sql
fi
log_info "正在关闭容器"
docker stop aicall outcallserver freeswitch
sleep 10
log_info "重命名aicall容器:aicall_date +%Y%m%d"
docker rename aicall aicall_`date +%Y%m%d`
log_info "重命名outcallserver容器:outcallserver_date +%Y%m%d"
docker rename outcallserver outcallserver_`date +%Y%m%d`
log_info "重命名freeswitch容器:outcallserver_date +%Y%m%d"
docker rename freeswitch freeswitch_`date +%Y%m%d`
log_info "备份配置文件,备份目录$back_path"
cp /etc/pbx/aicall $back_path -r
cp /etc/pbx/outcall_server $back_path -r
cp /etc/pbx/freeswitch $back_path -r