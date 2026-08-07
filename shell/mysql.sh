#!/bin/bash

#Date/Time ENV
CDATE=$(date "+%Y-%m-%d")
CTIME=$(date "+%H:%M:%S")

#Release ENV
RELEASE_BAKUP="bakup"
RELEASE_SQL_UPDATE="${RELEASE_BAKUP}/updateaicall_current.sql"
RELEASE_SQL_UPDATE_FENKU="${RELEASE_BAKUP}/updateaicall_fenku_current.sql"
RELEASE_SQL_BACK="${RELEASE_BAKUP}/back.sql"

#Shell ENV
SHELL_DIR="/tmp"
SHELL_NAME="mysql"
SHELL_LOG="${SHELL_DIR}/${SHELL_NAME}-${CDATE}.log"

SHELL_SQL_INSTALL="mysql/add_table.sql"
SHELL_SQL_UPDATE="mysql/updateaicall.sql"
SHELL_SQL_UPDATE_FENKU="mysql/updateaicall_fenku.sql"

#Mysql ENV
MYSQL_HOST="rm-2ze4h4gd92r731iapeo.mysql.rds.aliyuncs.com"
MYSQL_USER="emi_ai"
MYSQL_PASSWORD="Sinicnet123456"
MYSQL_DATABASE="ai"
MYSQL_DATABASE_FENKU="aicall_0"
#--set-gtid-purged=OFF
MYSQL_DATABASE_VAIRABLE="--single-transaction --set-gtid-purged=OFF"

#Error CODE
ERROR_DEFAULT=1
SUCCESS=0

OLD_VERSION=67320
NEW_VERSION=99999

usage() {
	echo $"Usage: $0
	install [new version] 安装数据库表结构及数据
	update [new version] 升级数据库表结构及数据"
}

shell_exit() {
	writelog "exit shell."
	exit $1
}

writelog() {
	LOGINFO=$1
	echo "${LOGINFO}"
	echo "${CDATE} ${CTIME} ${SHELL_NAME}: ${LOGINFO}" >> ${SHELL_LOG}
}

input_check() {
	writelog "$1"
	if [[ -n $2 ]];then
	    read -r -p "Please input your command(default:$2) " input
	else
	    read -r -p "Please input your command " input
	fi
	writelog ${input}
	case ${input} in
		[yY][eE][sS]|[yY])
			writelog "read Yes"
			return ${SUCCESS}
			;;
		[nN][oO]|[nN])
			writelog "read No"
			return ${ERROR_DEFAULT}
			;;
		*)
			writelog "read invalid input:${input}"
			return ${ERROR_DEFAULT}
			;;
	esac
}

version_check() {
    sql="SELECT value FROM aicall_config WHERE key='database_version'";
    old_web_ver=`mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} -ss -e "${sql}"`
    writelog "旧数据库版信息:$old_web_ver"
    if [[ -z ${old_web_ver} ]];then
        writelog "没有找到数据库版信息！"
        shell_exit ${ERROR_DEFAULT}
    fi
	writelog "old_web_ver #${old_web_ver}#"
	new_web_ver=$1
	writelog "new_web_ver #${new_web_ver}#"
	if [[ ${new_web_ver} -le ${old_web_ver} ]];then
		writelog "current version is ${old_web_ver}, new version is ${new_web_ver}, new version is same or smaller!" && shell_exit ${ERROR_DEFAULT}
	fi
}

cut_db_file() {
  	dbversion=0

  	cat $1|sed s'/ //g'|grep "^\/\*"|awk -F "*" '{print $2}'|grep '^[0-9]*$' >serial.txt
  	sed -i s'/ //g' serial.txt
  	for serialnum in $(<serial.txt)
  	do
  	{
      	if [[ "$2" -ge "$serialnum" ]]
      	then
          	dbversion=${serialnum}
      	fi
  	}
  	done
  	if [[ "$1" == "mobile.sql" ]]
    then
        sed -n '/^\/\*'${dbversion}'/,/EOF$/p' $1 >$3
        #找到升级节点后的执行sql
		#cat $1 |grep -A 1000000 "/\*${dbversion}"| grep -v "/\*${dbversion}"|grep -v "^\/\*" > $3
    else
        echo $4 > $3
        sed -n '/^\/\* *'${dbversion}'/,/EOF$/p' $1 >>$3
  	fi
	rm serial.txt -rf
}

mysql_check() {
	mysql --version
	if [[ $? -ne 0 ]];then
		writelog "mysql package is not installed."
		shell_exit ${ERROR_DEFAULT}
	fi
	mysql --version | grep "Distrib 5.7"
	if [[ $? -ne 0 ]];then
	    MYSQL_DATABASE_VAIRABLE="--single-transaction"
	fi
}

mysql_bakup() {
	writelog "mysql bakup[$old_web_ver]..."
	#backup mysql
	writelog "backup mysql begin"

	if [[ ! -d ${RELEASE_BAKUP} ]];then
		mkdir ${RELEASE_BAKUP}
	fi
	if [[ -f "$RELEASE_SQL_BACK" ]];then
		rm $RELEASE_SQL_BACK -rf
	fi
	if [[ -f "$RELEASE_SQL_UPDATE" ]];then
		rm $RELEASE_SQL_UPDATE -rf
	fi

	cut_db_file ${SHELL_SQL_UPDATE} ${old_web_ver} "$RELEASE_SQL_UPDATE" "SET NAMES utf8;"
	db_table=`cat ${RELEASE_SQL_UPDATE}|grep "^\/\*"|awk -F "*" '{print $2}'|grep '^#'|awk -F '#' '{{for(i=1;i<=NF;i++)if($i !=""){print $i}}}'|sort|uniq|awk '{printf("%s",c$0);c=" "}END{print""}'`
	writelog "backup talk table $db_table"
	if [[ "$db_table" != "" ]]; then
		mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -R -E ${MYSQL_DATABASE_VAIRABLE} ${MYSQL_DATABASE} ${db_table} > ${RELEASE_SQL_BACK} 2>>${SHELL_LOG}
		result_sql=$?
        if [[ ${result_sql} -ne 0 ]]; then
            writelog "/**********************/"
            writelog "backup talk sql error!,result=$result_sql"
            writelog "/**********************/"
            shell_exit ${ERROR_DEFAULT}
        fi
	fi
	writelog "bakup mysql over"
}

mysql_recovery() {
	writelog "mysql recovery..."
	#recover mysql
	writelog "recover mysql begin"
	if [[ -f ${RELEASE_SQL_BACK} ]];then
		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE}<${RELEASE_SQL_BACK} 2>>${SHELL_LOG}
		result_sql=$?
		if [[ ${result_sql} -ne 0 ]];then
			writelog "##**********************##"
			writelog "recover error!,result=$result_sql"
			writelog "##**********************##"
			shell_exit ${ERROR_DEFAULT}
		fi
	else
		writelog "back.sql not exist"
	fi
	writelog "recover mysql over"
}

mysql_install_fun() {
	writelog "mysql install fun..."
	mysql_check
	ai=`echo "show databases;"|mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD"|grep ${MYSQL_DATABASE}`
	if [[ -n "$ai" ]];then
		input_check "Database [$MYSQL_DATABASE] is installed, are you sure to continue and delete the database? {Y/N}" "N"
		if [[ $? -ne ${SUCCESS} ]]; then
			writelog "skip database [$MYSQL_DATABASE] reinstall."
			return ${ERROR_DEFAULT}
		fi
	fi
	writelog "install database [$MYSQL_DATABASE]..."
	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "DROP DATABASE IF EXISTS ${MYSQL_DATABASE};CREATE DATABASE ${MYSQL_DATABASE} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} < ${SHELL_SQL_INSTALL}
	if [[ $? -ne 0 ]];then
		writelog "mysql insert table failed.·¯(>▂<)¯·."
		shell_exit ${ERROR_DEFAULT}
	fi
	writelog "prepare to delete sub databases..."
	fenku_file="fenku.txt"
	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "show databases" | grep ${MYSQL_DATABASE_FENKU} > ${fenku_file}
	for i in `cat ${fenku_file}`
	do
		writelog "delete $i"
		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "drop database ${i}"
		if [[ $? -ne 0 ]]; then
			writelog "database $i delete failed."
		else
			writelog "database $i delete success."
		fi
    done
    rm -f ${fenku_file}
    writelog "sub databases clean end."
	writelog "install database [$MYSQL_DATABASE] success."
	return ${SUCCESS}
}

mysql_fenku_fun() {
	fenku_file="fenku.txt"
  	if [[ ! -f "$fenku_file" ]];then
    	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "show databases" | grep ${MYSQL_DATABASE_FENKU} > ${fenku_file}
  	fi
  	cut_db_file ${SHELL_SQL_UPDATE_qFENKU} ${old_web_ver} "$RELEASE_SQL_UPDATE_FENKU" "SET NAMES utf8;"
	fenku_db_table=`cat ${RELEASE_SQL_UPDATE_FENKU}|grep "^\/\*"|awk -F "*" '{print $2}'|grep '^#'|awk -F '#' '{{for(i=1;i<=NF;i++)if($i !=""){print $i}}}'|sort|uniq|awk '{printf("%s",c$0);c=" "}END{print""}'`

  	thead_num=4 #自定义并发数，根据自身服务器性能或应用调整大小，开始千万别定义太大，避免管理机宕机
  	tmp_fifo_file="/tmp/$$.fifo"  #以进程ID号命名管道文件
  	mkfifo ${tmp_fifo_file}   #创建临时管道文件
  	exec 4<>${tmp_fifo_file}  #以读写方式打开tmp_fifo_file管道文件,文件描述符为4，也可以取3-9任意描述符
  	rm -f ${tmp_fifo_file}    #删除临时管道文件

  	for ((i=0;i<$thead_num;i++))   #利用for循环向管道中输入并发数量的空行
  	do
       echo ""  #输出空行
  	done >&4  #输出重导向到定义的文件描述符4上

  	for i in `cat ${fenku_file}`
    do
    	read -u4 #从管道中读取行，每次一行，所有行读取完毕后执行挂起，直到管道有空闲的行
      	{
    	writelog $i
    	mkdir -p ${RELEASE_BAKUP}/${i}
    	mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -R -E -d ${MYSQL_DATABASE_VAIRABLE} ${i} > ${RELEASE_BAKUP}/${i}/${i}_tmp.sql
    	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "CREATE DATABASE ${i}_tmp DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"
      	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${i}_tmp < ${RELEASE_BAKUP}/${i}/${i}_tmp.sql
      	if [[ $? -ne 0 ]]; then
      		writelog "模拟数据库导入失败:mysql -h$MYSQL_HOST -u$MYSQL_USER -p"${MYSQL_PASSWORD}" ${i}_tmp < $RELEASE_BAKUP/${i}/${i}_tmp.sql"
      		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "drop database ${i}_tmp"
			sleep 3
			echo "" >&4
			continue
      	fi
      	writelog "模拟数据库导入成功！"
      	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${i}_tmp < ${RELEASE_SQL_UPDATE_FENKU} 2>>${SHELL_LOG}
      	if [[ $? -ne 0 ]]; then
			writelog "$i 模拟升级失败！"
			mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "drop database ${i}_tmp"
			sleep 3
			echo "" >&4
			continue
      	fi
      	writelog "模拟数据库升级成功！"
      	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "drop database ${i}_tmp"
        mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -R -E ${MYSQL_DATABASE_VAIRABLE} ${i} ${fenku_db_table} >${RELEASE_BAKUP}/${i}/${i}_back.sql 2>>${SHELL_LOG}
        if [[ $? -ne 0 ]]; then
        	writelog "$i 备份失败，备份表：$fenku_db_table"
        	sleep 3
        	echo "" >&4
        	continue
      	else
        	writelog "$i 备份完成"
        	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${i} < ${RELEASE_SQL_UPDATE_FENKU} 2>>${SHELL_LOG}
        	if [[ $? -ne 0 ]]; then
          		writelog "$i 数据库升级失败"
				mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${i} <${RELEASE_BAKUP}/${i}/${i}_back.sql 2>>${SHELL_LOG}
				if [[ $? -ne 0 ]]; then
					writelog "$i 数据库升级失败,备份表恢复失败"
				else
					writelog "$i 数据库升级失败,备份表恢复完成"
				fi
        	else
          		writelog "$i 数据库升级完成"
          		sed -i "/$i/d" ${fenku_file}
          		sleepnum=`expr $RANDOM % 20`
          		sleep ${sleepnum}
          		sed -i "/$i/d" ${fenku_file}
        	fi
        fi
        sleep 3
        echo "" >&4
        }&
    done
    wait  #等待所有后台进程执行完成
    exec 4>&-  #删除文件描述符
    writelog "所有库循环完成"
}

mysql_update_fun() {
	writelog "准备升级数据库..."
	db_file="db.txt"
  	if [[ ! -f "$db_file" ]];then
    	 echo ${MYSQL_DATABASE} > ${db_file}
    else
    	if [[ `cat ${db_file} | wc -l` -eq 0 ]];then
    		writelog "$db_file update finished, skip this update."
    	    return ${SUCCESS}
    	fi
  	fi
  	mysql_check
  	mysql_bakup
	if [[ -f "$RELEASE_SQL_UPDATE" ]];then
		cat ${RELEASE_SQL_UPDATE}
		mkdir -p ${RELEASE_BAKUP}/${MYSQL_DATABASE}
		mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -R -E -d ${MYSQL_DATABASE_VAIRABLE} ${MYSQL_DATABASE} > ${RELEASE_BAKUP}/${MYSQL_DATABASE}/${MYSQL_DATABASE}_tmp.sql
		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "CREATE DATABASE ${MYSQL_DATABASE}_tmp DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci" 2>>${SHELL_LOG}
		if [[ $? -ne 0 ]]; then
      	    writelog "数据库${MYSQL_DATABASE}_tmp 创建失败!"
      	    shell_exit ${ERROR_DEFAULT}
      	fi
      	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE}_tmp < ${RELEASE_BAKUP}/${MYSQL_DATABASE}/${MYSQL_DATABASE}_tmp.sql 2>>${SHELL_LOG}
      	if [[ $? -ne 0 ]]; then
      		writelog "模拟数据库导入失败:mysql -h$MYSQL_HOST -u$MYSQL_USER -p"${MYSQL_PASSWORD}" ${MYSQL_DATABASE}_tmp < $RELEASE_BAKUP/${MYSQL_DATABASE}/${MYSQL_DATABASE}_tmp.sql"
      		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "drop database ${MYSQL_DATABASE}_tmp"
			sleep 3
      	    shell_exit ${ERROR_DEFAULT}
      	fi
      	if [[ -f ${RELEASE_SQL_BACK} ]];then
      	    writelog "模拟数据库导入备份数据文件!"
      	    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE}_tmp < ${RELEASE_SQL_BACK} 2>>${SHELL_LOG}
        else
      	    writelog "模拟数据库导入的备份数据文件不存在!"
      	fi
      	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE}_tmp < ${RELEASE_SQL_UPDATE} 2>>${SHELL_LOG}
      	if [[ $? -ne 0 ]]; then
			writelog "$RELEASE_SQL_UPDATE 模拟升级失败！"
			mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "drop database ${MYSQL_DATABASE}_tmp"
			sleep 3
			shell_exit ${ERROR_DEFAULT}
		else
		    writelog "模拟数据库升级成功！"
		    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "drop database ${MYSQL_DATABASE}_tmp"
      	fi
		writelog "数据库开始升级..."
		mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} < ${RELEASE_SQL_UPDATE} 2>>${SHELL_LOG}
		if test $? -eq 0; then
			sed -i "/$MYSQL_DATABASE/d" ${db_file}
			writelog "数据库升级完成!"
		else
			mysql_recovery
			writelog "数据库升级失败:: sql exec :mysql -h$MYSQL_HOST -u$MYSQL_USER -p'$MYSQL_PASSWORD' <${RELEASE_SQL_UPDATE}"
			shell_exit ${ERROR_DEFAULT}
		fi
	fi
}

mysql_update_result() {
	writelog "mysql update result."
	if [[ `cat ${db_file} | wc -l` -ne 0 ]];then
		writelog "$db_file is not end, please retry."
    	shell_exit ${ERROR_DEFAULT}
    else
    	writelog "$MYSQL_DATABASE has updated."
	fi
	writelog "mysql update result0."
	if [[ `cat ${fenku_file} | wc -l` -ne 0 ]];then
		writelog "$fenku_file is not end, please retry."
		writelog "mysql update result1."
    	shell_exit ${ERROR_DEFAULT}
    else
    	writelog "$MYSQL_DATABASE_FENKU has updated."
    	writelog "mysql update result2."
	fi
}

mysql_version_update()
{
	writelog "更新数据库版本：$1"
	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} -ss -e "INSERT INTO aicall_config (\`eid\`, \`key\`, \`value\`, \`status\`, \`describe\`, \`type\`) VALUES (0,'database_version', '$1', 1, '数据库版本', 0)" 2>>${SHELL_LOG}
	if test $? -ne 0; then
	    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} -ss -e "UPDATE aicall_config SET \`value\` = '$1' WHERE \`key\` = 'database_version'" 2>>${SHELL_LOG}
	fi
}

main() {

	DEPLOY_METHOD=$1
	DEPLOY_DATA=$2

	case ${DEPLOY_METHOD} in
		install)
			mysql_install_fun
			mysql_version_update ${DEPLOY_DATA}
			;;
		update)
		    version_check ${DEPLOY_DATA}
			mysql_update_fun
			mysql_fenku_fun
			mysql_update_result
			mysql_version_update ${DEPLOY_DATA}
			;;
		*)
			usage
	esac
}

main "$1" "$2"
exit ${SUCCESS}
