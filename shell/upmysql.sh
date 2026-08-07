#!/bin/bash
#更新前的aicall版本以及需要操作的sql语句目录
RELEASE_DIR=/var/pbx/release

RELEASE_SQL_UPDATE=${RELEASE_DIR}/updateaicall_current.sql
               

#需要更新的aicall版本以及当前所有的updateaicall.sql语句
RELEASE_PROJECT=/var/pbx/website

SHELL_SQL_UPDATE=${RELEASE_PROJECT}/shell/mysql/updateaicall.sql

#需要备份的数据库表目录
RELEASE_BACKUP=/var/pbx/backup
RELEASE_SQL_BACK=/var/pbx/backup/aicallback.sql

#数据库
SERVER_DB_LIST=127.0.0.1
MYSQL_HOST=${SERVER_DB_LIST}
MYSQL_USER="emi_web"
MYSQL_PASSWORD="Sinicnet@123456"
MYSQL_DATABASE="ai"
MYSQL_DATABASE_VAIRABLE="--single-transaction --set-gtid-purged=OFF"

#log目录
SHELL_NAME=mysql.sh
SHELL_LOG=/var/pbx/logs/${SHELL_NAME}.log



#获取版本
function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
   
}

function log_warn() {
    echo -e "\033[33m [WARN] $@ \033[0m"
   
}

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
    
}
#获取版本号
贷款是免息的吗？
贷款收多少手续费？
贷款会更优惠吗？会在优惠基础上再优惠多少
version_get(){
     filename=${SHELL_SQL_UPDATE}
     sed -n '/^\/\*[0-9]/p' ${filename} >> all_version.txt
     awk -F ':' '{print $2}' all_version.txt|sort -n > all_version.txt
     new_version=`sed -n '$p' all_version.txt`

     echo "此次升级版本：${new_version}"
}   
#版本对比
version_check(){
    #下面一行代码等军哥的定义数据库版本的字段出来在写
    docker exec -it emic_mysql mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e 'select * from aicall_config where'
    old_version=

    log_info "当前版本:"${old_version}""

    log_info "升级版本:"${new_version}""
    if [[ "${old_version}" -gt ${new_version} ]];then
    log_warn "当前版本${old_version}  升级版本${new_version}"  "当前版本要升级版本高，不需升级"
    else
    log_info "准备数据库升级工作"

    fi
}

#切割数据库
cut_db(){

    dbversion=0
    for num in `cat all_version.txt`
    do
       if [[ "${old_version}" -ge "$num" ]];then
         dbversion=$num
       fi
    done
    echo "SET NAMES utf8;" > ${RELEASE_SQL_UPDATE}
    sed -n '/^\/\*'"${dbversion}"'/,/$p/p' ${SHELL_SQL_UPDATE} >> ${RELEASE_SQL_UPDATE}
    rm all_version.txt -rf
}

#数据库备份
mysql_bakup() {
        cat << EOF
+-------------------------------------------------+
                开始数据库切割                  
+-------------------------------------------------+
EOF

	log_info "mysql backup "${old_version}""

	if [[ ! -d ${RELEASE_BACKUP} ]];then
        log_info "++++++创建数据备份目录+++++++ /var/pbx/backup"
		mkdir ${RELEASE_BACKUP}
        else log_info "数据备份目录：/var/pbx/backup "
	fi
#删除/var/pbx/backup下面aicallback.sql
	if [[ -f "$RELEASE_SQL_BACK" ]];then
        log_info "删除文件：${RELEASE_SQL_BACK}"
		rm ${RELEASE_SQL_BACK} -rf
	fi
#删除之前的/var/pbx/release/下updateaicall_current.sql
	if [[ -f "${RELEASE_SQL_UPDATE}" ]];then
        log_info "删除文件：${RELEASE_SQL_UPDATE}"
        rm ${RELEASE_SQL_UPDATE} -rf
	fi
    #调用切割数据库函数
	cut_db
    #备份改动的表
            cat << EOF
+-------------------------------------------------+
                判断数据库表是否变更              
+-------------------------------------------------+
EOF
	db_table=`cat ${RELEASE_SQL_UPDATE}|grep "^\/\*"|awk -F "*" '{print $2}'|grep '^#'|awk -F '#' '{{for(i=1;i<=NF;i++)if($i !=""){print $i}}}'|sort|uniq|awk '{printf("%s",c$0);c=" "}END{print""}'`
	
	if [[ "$db_table" != "" ]]; then
        log_info "${db_table}发生变更"
        log_info "backup  table $db_table"
		mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -R -E ${MYSQL_DATABASE_VAIRABLE} ${MYSQL_DATABASE} ${db_table} > ${RELEASE_SQL_BACK} 2>>${SHELL_LOG}
		result_sql=$?
    else
        log_info "未有表变更"
        if [[ "${result_sql}" -ne 0 ]]; then
            log_error "/**********************/"
            log_error "backup talk sql error!"
            log_error "/**********************/"
        fi
	fi
#备份数据库整库表结构
#表结构是追加的,mysql_bakup函数未删除 ai_tmp.sql
        cat << EOF
+-------------------------------------------------+
                整库表结构备份开始                
+-------------------------------------------------+
EOF
	 mkdir -p  ${RELEASE_BACKUP}/${MYSQL_DATABASE}
     mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -R -E -d ${MYSQL_DATABASE_VAIRABLE} ${MYSQL_DATABASE} > ${RELEASE_BACKUP}/${MYSQL_DATABASE}/${MYSQL_DATABASE}_tmp.sql
     log_info "整库表结构备份sql：${RELEASE_BACKUP}/${MYSQL_DATABASE}/${MYSQL_DATABASE}_tmp.sql"

}

mysql_update_fun() {
        cat << EOF
+-------------------------------------------------+
                  准备升级数据库                    
+-------------------------------------------------+
EOF
        version_get
        version_check
  	    mysql_bakup
    if [[ -f "$RELEASE_SQL_UPDATE" ]];then
        log_info "创建零时数据库：${MYSQL_DATABASE}_tmp"
		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "CREATE DATABASE ${MYSQL_DATABASE}_tmp DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci" 2>>${SHELL_LOG}
		if [[ $? -ne 0 ]]; then
      	log_error "数据库${MYSQL_DATABASE}_tmp 创建失败!"
        exit
      	fi
      	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE}_tmp < ${RELEASE_BACKUP}/${MYSQL_DATABASE}/${MYSQL_DATABASE}_tmp.sql 2>>${SHELL_LOG}
      	if [[ $? -ne 0 ]]; then
      		log_error "模拟整库导入失败:mysql -h$MYSQL_HOST -u$MYSQL_USER -p"${MYSQL_PASSWORD}" ${MYSQL_DATABASE}_tmp < $RELEASE_BACKUP/${MYSQL_DATABASE}/${MYSQL_DATABASE}_tmp.sql"
            log_info "删除零时数据库：${MYSQL_DATABASE}_tmp"
      		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "drop database ${MYSQL_DATABASE}_tmp"
			sleep 3
      	    exit 
        else  
            log_info "模拟整库导入成功"                 
        fi
      	if [[ -f ${RELEASE_SQL_BACK} ]];then
      	    log_info "模拟数据库导入备份表!"
      	    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE}_tmp < ${RELEASE_SQL_BACK} 2>>${SHELL_LOG}
        else
      	    log_info "无表结构变化,不需导入!"
      	fi
      	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"${MYSQL_PASSWORD}" ${MYSQL_DATABASE}_tmp < ${RELEASE_SQL_UPDATE} 2>>${SHELL_LOG}
      	if [[ $? -ne 0 ]]; then
			log_error "${RELEASE_SQL_UPDATE} 模拟升级失败！"
			mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"${MYSQL_PASSWORD}" -ss -e "drop database ${MYSQL_DATABASE}_tmp"
			sleep 3
			exit 
		else
		    log_info "模拟数据库升级成功！"
		    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"${MYSQL_PASSWORD}" -ss -e "drop database ${MYSQL_DATABASE}_tmp"
      	fi
        cat << EOF
+-------------------------------------------------+
                 正式升级数据库                    
+-------------------------------------------------+
EOF
		log_info "数据库开始升级..."
        log_info "正在执行${RELEASE_SQL_UPDATE}"
        log_info "数据库升级部分如下"
        cat ${RELEASE_SQL_UPDATE}
        mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} < ${RELEASE_SQL_UPDATE} 2>>${SHELL_LOG}
		if  [[ $? -eq 0 ]];then
			log_info "数据库升级完成!"
            
            sleep 3
		else
			mysql_recovery
			log_error " 数据库升级失败 sql exec fail:: mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"${MYSQL_PASSWORD}"  <${RELEASE_SQL_UPDATE} "
			exit
		fi
    else 
        log_warn "数据库切割文件：${RELEASE_SQL_UPDATE}不存在 "
    fi
}
        
#数据库还原
mysql_recovery() {
       cat << EOF
+-------------------------------------------------+
                  正在还原数据库                   
+-------------------------------------------------+
EOF
	log_info "mysql recovery..."
	log_info "recover mysql begin"
	if [[ -f ${RELEASE_SQL_BACK} ]];then
		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"${MYSQL_PASSWORD}" ${MYSQL_DATABASE}<${RELEASE_SQL_BACK} 2>>${SHELL_LOG}
		result_sql=$?
		if [[ ${result_sql} -ne 0 ]];then
			log_error "##**********************##"
			log_error "     recover error！！！   "
			log_error "##**********************##"
			exit 
		fi
	else
		log_warn "back.sql not exist"
	fi
	log_info "recover mysql over"
}
mysql_update_fun