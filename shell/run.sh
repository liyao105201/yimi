#!/bin/bash

#Node List
SERVER_DB_LIST="rm-2ze4h4gd92r731iapeo.mysql.rds.aliyuncs.com"
SERVER_OC=""
SERVER_CACHE_LIST="47.94.139.172"
SERVER_MOUDLE="*"
SERVER_DOMAIN_SYSTEM="ai.emic.com.cn"
SERVER_DOMAIN_API="emirobotapi.emic.com.cn"

#Date/Time ENV
CDATE=$(date "+%Y-%m-%d")
CTIME=$(date "+%H:%M:%S")

#Release ENV
RELEASE_DIR="/var/pbx"
RELEASE_ASR="${RELEASE_DIR}/asr"
RELEASE_TAR="${RELEASE_DIR}/release"
RELEASE_TMP="${RELEASE_DIR}/tmp"
RELEASE_PROJECT="${RELEASE_DIR}/website"
RELEASE_BAKUP="${RELEASE_DIR}/bakup"
RELEASE_LOGS="${RELEASE_DIR}/logs"
RELEASE_UPLOAD="${RELEASE_DIR}/upload/robot"
RELEASE_CACHE="${RELEASE_PROJECT}/runtime"
RELEASE_CRONTAB_DIR="${RELEASE_PROJECT}/crontab"
RELEASE_CRONTAB_FILE="${RELEASE_CRONTAB_DIR}/www-data.cron"
RELEASE_SQL_UPDATE="${RELEASE_BAKUP}/updateaicall_current.sql"
RELEASE_SQL_UPDATE_FENKU="${RELEASE_BAKUP}/updateaicall_fenku_current.sql"
RELEASE_SQL_BACK="${RELEASE_BAKUP}/back.sql"
RELEASE_USER="root"
RELEASE_TAG="aicall"
RELEASE_VERSION_FILE="aicall_version.txt"
RELEASE_VERSION_KEY="product version"
RELEASE_TAG_EXTENSION=".tar.gz"

#Shell ENV
SHELL_DIR="/tmp"
SHELL_NAME="run.sh"
SHELL_LOG="${SHELL_DIR}/${SHELL_NAME}.log"
SHELL_LOCK="${SHELL_DIR}/${SHELL_NAME}.lock"
SHELL_ROOT=".."
SHELL_PATH="shell"
SHELL_CRONTAB_SH="cron/crontab.sh"
SHELL_CRONTAB_API="cron/api"
SHELL_CRONTAB="cron/crontab"
SHELL_NGINX_CONF="nginx/nginx.conf"
SHELL_NGINX_CONF_SYSTEM="nginx/conf.d/default.conf"
SHELL_NGINX_CONF_API="nginx/conf.d/api.conf"
SHELL_NGINX_CRT="nginx/crt"
SHELL_SQL_INSTALL="mysql/add_table.sql"
SHELL_SQL_UPDATE="mysql/updateaicall.sql"
SHELL_SQL_UPDATE_FENKU="mysql/updateaicall_fenku.sql"

#Code ENV
CODE_CONFIG="config/config.php"
CODE_CONFIG_DATABASE="config/database.php"
CODE_CONFIG_CORE="extend/core/common/config.php"

#Nginx ENV
NGINX_PATH="/etc/nginx"

#Mysql ENV
MYSQL_HOST=${SERVER_DB_LIST}
MYSQL_USER="emi_ai"
MYSQL_PASSWORD="Sinicnet123456"
MYSQL_DATABASE="ai"
MYSQL_DATABASE_FENKU="aicall_0"
#--set-gtid-purged=OFF
MYSQL_DATABASE_VAIRABLE="--single-transaction --set-gtid-purged=OFF"

#Error CODE
ERROR_DEFAULT=1
SUCCESS=0

usage() {
	echo $"Usage: $0
	init 环境初始化
	conf [ db ip&engine ip ] 配置数据库服务器的地址及OC服务器的地址
	install 安装系统
	update 升级系统
	rollback [ list | tar version ] 回滚至某一个系统版本
	mysqlconf [ db user&db password ] 配置数据库服务器的登录用户名及密码
	mysqlinstall 安装数据库表结构及数据
	mysqlupdate [old version] 升级数据库表结构及数据
	statistic 生成统计历史数据
	configoc 配置企业对应的oc地址
	join [service name] 接入第三方服务"
}

writelog() {
	LOGINFO=$1
	echo "${LOGINFO}"
	echo "${CDATE} ${CTIME} ${SHELL_NAME}: ${LOGINFO}" >> ${SHELL_LOG}
}

dpkg_check() {
	yum list installed |grep "$1" 1>>${SHELL_LOG} 2>>${SHELL_LOG}
	if [[ $? -ne 0 ]];then
		writelog "The program '$1' is currently not installed."
	    shell_exit ${ERROR_DEFAULT}
	else
		writelog "$1 is installed."
	fi
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

crontab() {
    if [[ ${SERVER_MOUDLE} != "api" ]];then
        su www-data -c "source '${SHELL_CRONTAB_SH}' '${SHELL_CRONTAB}' '${RELEASE_CRONTAB_DIR}' '${RELEASE_CRONTAB_FILE}'"
        writelog "crontab apply success."
    else
        su www-data -c "source '${SHELL_CRONTAB_SH}' '${SHELL_CRONTAB_API}' '${RELEASE_CRONTAB_DIR}' '${RELEASE_CRONTAB_FILE}'"
        writelog "api server apply crontab success."
    fi
}
#RELEASE_VERSION_FILE="aicall_version.txt"
#RELEASE_VERSION_KEY=pruduct version
#version_get "${RELEASE_PROJECT}/${RELEASE_VERSION_FILE}" "${RELEASE_VERSION_KEY}"
获得未升级前的aicall版本
version_get()
{
	filename=$1
	line_content=$2
	#RELEASE_PROJECT=/var/pbx/website   输出website下的aicall版本
	line=`sed -n '/^'"${line_content}"' *\:/p' $1`
	#retvalue 输出数字部分可用awk替换
	retvalue=`echo ${line}|sed -e 's/^'"${line_content}"' *: *//'`
	echo ${retvalue}
}

#version_check 检查/var/pbx/release下的aicall的版本和要升级的版本是否一致
version_check() {
    #if [[ "$1" -gt 0 ]] 2>/dev/null ;then
        #old_web_ver="$1"
    #else
        if [[ ! -f "${RELEASE_PROJECT}/${RELEASE_VERSION_FILE}" ]];then
		writelog "No current version is found, please install!" && shell_exit ${ERROR_DEFAULT}
	    fi
	    old_web_ver=(`version_get "${RELEASE_PROJECT}/${RELEASE_VERSION_FILE}" "${RELEASE_VERSION_KEY}"`)
    #fi
	writelog "old_web_ver #${old_web_ver}#"
	#获得解压后文件夹下的aicall版本
	new_web_ver=(` "${SHELL_ROOT}/${RELEASE_VERSION_FILE}"  "${RELEASE_VERSION_KEY}"`)
	writelog "new_web_ver #${new_version_getweb_ver}#"
	if [[ ${new_web_ver} -le ${old_web_ver} ]];then
		writelog "current version is ${old_web_ver}, new version is ${new_web_ver}, new version is same or smaller!" && shell_exit ${ERROR_DEFAULT}
	fi
}


#  cut_db_file ${SHELL_SQL_UPDATE} ${old_web_ver} "$RELEASE_SQL_UPDATE" "SET NAMES utf8;"
cut_db_file() {
  	dbversion=0
    #获得升级的update.sql的所有版本号
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
		#将当前的updateaicall.sql的未更新版本 复制到updateaicall_current.sql （$3）
        sed -n '/^\/\* *'${dbversion}'/,/EOF$/p' $1 >>$3
  	fi 
	rm serial.txt -rf
}

shell_lock() {
	touch ${SHELL_LOCK}
}

shell_unlock() {
	rm -rf ${SHELL_LOCK}
}
shell_is_lock() {
	if [[ $1 = "ignorelock" ]];then
		return ${SUCCESS}
	fi
	if [[ -f ${SHELL_LOCK} ]];then
		writelog "shell is running" && exit ${ERROR_DEFAULT}
	fi
}

shell_exit() {
	writelog "exit shell."
	shell_unlock
	exit $1
}

check_result() {
	$1 1>>${SHELL_LOG} 2>>${SHELL_LOG}

	cmd_result_common=`echo $?`
	if [[ ${cmd_result_common} -ne 0 ]];then
		if [[ -n "$2" ]];then
			writelog "cmd error : $1, execute : $2"
			$2
		else
			writelog "cmd error : $1"
		fi
		shell_exit ${ERROR_DEFAULT}
	fi
}

init() {
	if [[ `whoami` != ${RELEASE_USER} ]];then
		writelog "sorry, you are not ${RELEASE_USER}."
		shell_exit ${ERROR_DEFAULT}
	fi
	if [[ ! -d ${RELEASE_DIR} ]];then
		mkdir ${RELEASE_DIR}
	fi
	if [[ ! -d ${RELEASE_TAR} ]];then
		mkdir ${RELEASE_TAR}
	fi
	if [[ ! -d ${RELEASE_PROJECT} ]];then
		mkdir ${RELEASE_PROJECT}
	fi
	if [[ ! -d ${RELEASE_TMP} ]];then
		mkdir -p ${RELEASE_TMP}/logs
	fi
	if [[ ! -d ${RELEASE_LOGS} ]];then
		mkdir -p ${RELEASE_LOGS}
	fi
	if [[ ! -d ${RELEASE_UPLOAD} ]];then
		mkdir -p ${RELEASE_UPLOAD}
	fi
}

file_bakup() {
	if [[ ! -f "$1.bak" ]];then
		cp -rf $1 $1.bak
		writelog "bakup $1"
	else
		writelog "$1.bak is exist."
	fi
}

shell_conf() {
	SERVER_LIST=$1
	if [[ -n "$SERVER_LIST" ]];then
		writelog "config server list[${SERVER_LIST}]"
		SERVER_DB_LIST_OLD=${SERVER_DB_LIST}
		SERVER_OC_OLD=${SERVER_OC}
		SERVER_CACHE_LIST_OLD=${SERVER_CACHE_LIST}
		OLD_IFS=$IFS
		IFS="&"
		i=0
		for value in ${SERVER_LIST}
		do
			writelog ${value}
			if [[ ${i} -eq 0 ]];then
				SERVER_DB_LIST=${value}
			elif [[ ${i} -eq 1 ]];then
				SERVER_OC=${value}
			elif [[ ${i} -eq 2 ]];then
				SERVER_CACHE_LIST=${value}
			fi
			let i++
		done
		IFS=${OLD_IFS}
		#update run.sh
		SHELL_FILE="$(cd `dirname $0`; pwd)/${0##*/}"
		sed -i "s/SERVER_DB_LIST=\"${SERVER_DB_LIST_OLD}\"/SERVER_DB_LIST=\"${SERVER_DB_LIST}\"/" ${SHELL_FILE}
		sed -i "s/SERVER_OC=\"${SERVER_OC_OLD}\"/SERVER_OC=\"${SERVER_OC}\"/" ${SHELL_FILE}
		sed -i "s/SERVER_CACHE_LIST=\"${SERVER_CACHE_LIST_OLD}\"/SERVER_CACHE_LIST=\"${SERVER_CACHE_LIST}\"/" ${SHELL_FILE}

		writelog "config shell successfully."
	fi
	input_check "The server is API Server {Y/N}" "N"
	if [[ $? -eq ${SUCCESS} ]]; then
	    SERVER_MOUDLE="api";
	    writelog "enable api deploy"
	else
	    if [[ ${input} = 'aicall' ]]; then
	        SERVER_MOUDLE="aicall";
	        writelog "disable api deploy"
	    fi
	fi
}

mysql_conf() {
	mysql_auth=$1
	if [[ -n "$mysql_auth" ]];then
		writelog "mysql config list[${mysql_auth}]"
		MYSQL_USER_OLD=${MYSQL_USER}
		MYSQL_PASSWORD_OLD=${MYSQL_PASSWORD}
		OLD_IFS=$IFS
		IFS="&"
		i=0
		for value in ${mysql_auth}
		do
			writelog ${value}
			if [[ ${i} -eq 0 ]];then
				MYSQL_USER=${value}
			elif [[ ${i} -eq 1 ]];then
				MYSQL_PASSWORD=${value}
			fi
			let i++
		done
		IFS=${OLD_IFS}
		#update run.sh
		SHELL_FILE="$(cd `dirname $0`; pwd)/${0##*/}"
		sed -i "s/MYSQL_USER=\"${MYSQL_USER_OLD}\"/MYSQL_USER=\"${MYSQL_USER}\"/" ${SHELL_FILE}
		sed -i "s/MYSQL_PASSWORD=\"${MYSQL_PASSWORD_OLD}\"/MYSQL_PASSWORD=\"${MYSQL_PASSWORD}\"/" ${SHELL_FILE}

		writelog "mysql config successfully."
	fi
}

server_conf() {
	version=`lsb_release -i`
	value=`echo ${version} | awk '{print $3}'`
	if [[ ${value} != "CentOS" ]];then
		writelog "this is other linux version." && shell_exit ${ERROR_DEFAULT}
	fi
	#copy nginx conf file
	wtype=$1
	writelog "config server type[$wtype]"
	if [[ ${wtype} = "web" ]];then
		file_bakup ${NGINX_PATH}/nginx.conf
		check_result "cp -rf ${SHELL_NGINX_CRT} ${NGINX_PATH}"
		check_result "cp -rf ${SHELL_NGINX_CONF} ${NGINX_PATH}"
        if [[ ${SERVER_MOUDLE} = "api" ]];then
            check_result "cp -rf ${SHELL_NGINX_CONF_API} ${NGINX_PATH}/conf.d/default.conf"
        else
            check_result "cp -rf ${SHELL_NGINX_CONF_SYSTEM} ${NGINX_PATH}/conf.d/default.conf"
        fi
	elif [[ ${wtype} = "mysql" ]];then
		dpkg_check "mysql"
	elif [[ ${wtype} = "redis" ]];then
		dpkg_check "redis"
	else
		writelog "unknow server type." && shell_exit ${ERROR_DEFAULT}
	fi
}

server_restart() {
	stype=$1
	writelog "restart server[${stype}]"
	if [[ ${stype} = "web" ]];then
		check_result "systemctl restart nginx"
		check_result "systemctl restart php-fpm"
	elif [[ ${stype} = "db" ]];then
		check_result "systemctl restart mysql"
	elif [[ ${stype} = "cache" ]];then
		check_result "systemctl restart redis"
		check_result "redis-cli flushdb"
	else
		writelog "unknow server type." && shell_exit ${ERROR_DEFAULT}
	fi
}

cache_delete() {
	writelog "cache delete"
	rm -rf ${RELEASE_CACHE}
}

convert(){
	keyword=${1//\\/\\\\\\\\}
	keyword=${keyword//\./\\.}
	keyword=${keyword//\*/\\*}
	keyword=${keyword//\&/\\&}
	keyword=${keyword//\$/\\$}
	keyword=${keyword//\+/\\+}
	keyword=${keyword//\=/\\=}
	keyword=${keyword//\^/\\^}
	keyword=${keyword//\%/\\%}
	keyword=${keyword//\!/\\!}
	keyword=${keyword//\@/\\@}
	keyword=${keyword//\#/\\#}
	keyword=${keyword//\[/\\[}
	keyword=${keyword//\]/\\]}
	echo ${keyword}
}
#CODE_CONFIG_DATABASE="config/database.php"   SHELL_ROOT=".."
#code_config是改config/config.php database.php 的对应配置的
#CODE_CONFIG_CORE="extend/core/common/config.php"
code_config() {
	writelog "code config"
    if [[ ${SERVER_MOUDLE} = "api" ]];then
        sed -i "s/'url_domain_root.*/'url_domain_root' => '$SERVER_DOMAIN_API',/" ${SHELL_ROOT}/${CODE_CONFIG}
    else
        sed -i "s/'url_domain_root.*/'url_domain_root' => '$SERVER_DOMAIN_SYSTEM',/" ${SHELL_ROOT}/${CODE_CONFIG}
    fi
	SERVER_DB_LIST_NEW=`echo ${SERVER_DB_LIST} | sed 's/[ ][ ]*/,/g'`
	sed -i "s/'hostname.*/'hostname' => '$SERVER_DB_LIST_NEW',/" ${SHELL_ROOT}/${CODE_CONFIG_DATABASE}
	sed -i "s/'username.*/'username' => '$MYSQL_USER',/" ${SHELL_ROOT}/${CODE_CONFIG_DATABASE}
	pwd=(`convert ${MYSQL_PASSWORD}`)
	sed -i "s/'password.*/'password' => '${pwd}',/" ${SHELL_ROOT}/${CODE_CONFIG_DATABASE}
	sed -i "s/'database.*/'database' => '$MYSQL_DATABASE',/" ${SHELL_ROOT}/${CODE_CONFIG_DATABASE}
	sed -i "s/'app_debug.*/'app_debug' => false,/" ${SHELL_ROOT}/${CODE_CONFIG}
	sed -i "s/'moudle_permited.*/'moudle_permited' => '$SERVER_MOUDLE',/" ${SHELL_ROOT}/${CODE_CONFIG_CORE}
	sed -i "s/'host.*/'host' => '$SERVER_CACHE_LIST',/" ${SHELL_ROOT}/${CODE_CONFIG_CORE}
	if [[ -n ${SERVER_OC} ]];then
	    writelog "config oc ip:[${SERVER_OC}] ..."
	    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} -ss -e "UPDATE aicall_config SET \`value\` = '${SERVER_OC}' WHERE \`key\` = 'outcall_server_host'" 2>>${SHELL_LOG}
	    writelog "config oc ip end."
	fi
}
#RELEASE_DIR="/var/pbx"
#RELEASE_PROJECT="${RELEASE_DIR}/website"  $1=${RELEASE_DIR}/website
#RELEASE_VERSION_FILE="aicall_version.txt"
#RELEASE_TAR="${RELEASE_DIR}/release"
#RELEASE_TAG="aicall"  RELEASE_TAG_EXTENSION=".tar.gz"


#code_tar 将/root下的init文件夹内容tar到 /var/pbx/release
code_tar() {
	TAG_PATH=$1
	writelog "code tar path[${TAG_PATH}]"
	if [[ -z ${TAG_PATH} ]];then
		ROOT_PATH=${SHELL_ROOT}
		BAKUP_EXTENSION=""
	else
		ROOT_PATH=${TAG_PATH}
		BAKUP_EXTENSION='.bakup'
	fi
	if [[ ! -f "${ROOT_PATH}/${RELEASE_VERSION_FILE}" ]];then
		writelog "first install, no old version exist"
		return ${SUCCESS}
	fi
	web_version=(`version_get "${ROOT_PATH}/${RELEASE_VERSION_FILE}"  "${RELEASE_VERSION_KEY}"`)
	if [[ -z ${web_version} ]];then
		TAG_NAME=""
	else
		TAG_NAME=${RELEASE_TAG}_${web_version}
	fi
	if [[ -z ${TAG_NAME} ]];then
		writelog "no version info finded"
		return ${SUCCESS}
	fi
#tar -C 将tar的工作目录切换到..处，将.(也 就是..后的本级目录全部压缩至${RELEASE_TAR}/${TAG_NAME}${RELEASE_TAG_EXTENSION}${BAKUP_EXTENSION} )
	tar czf ${RELEASE_TAR}/${TAG_NAME}${RELEASE_TAG_EXTENSION}${BAKUP_EXTENSION} -C ${ROOT_PATH} .
	if [[ $? -ne 0 ]];then
		writelog "tar failed .·¯(>▂<)¯·. [tar czf ${RELEASE_TAR}/${TAG_NAME}${RELEASE_TAG_EXTENSION}${BAKUP_EXTENSION} -C ${ROOT_PATH} .]"
		shell_exit ${ERROR_DEFAULT}
	fi
}

code_rollback() {
	writelog "code rollback[$TAG_NAME]"
	if [[ -z ${TAG_NAME} ]];then
		writelog "no version to rollback."
		return ${SUCCESS}
	fi
	check_result "cd ${RELEASE_TAR}"
	check_result "rm -rf ${TAG_NAME}"
	check_result "mkdir ${TAG_NAME}"
	check_result "tar -zxf ${TAG_NAME}${RELEASE_TAG_EXTENSION}${BAKUP_EXTENSION} -C ${TAG_NAME}"
	check_result "cd ${TAG_NAME}/${SHELL_PATH}"
	code_submit "from rollback"
	rm -rf ${RELEASE_TAR}/${TAG_NAME}
	rm -rf ${RELEASE_TAR}/${TAG_NAME}${RELEASE_TAG_EXTENSION}${BAKUP_EXTENSION}
	writelog "clean rollback temp files."
	writelog "code rollback end."
}
#RELEASE_DIR="/var/pbx"
#RELEASE_PROJECT="${RELEASE_DIR}/website"
code_submit() {
	if [[ -z $1 ]];then
		code_tar "${RELEASE_PROJECT}"
		writelog "backup current web[$TAG_NAME]"
		ROLLBACK_CMD="code_rollback"
	else
		ROLLBACK_CMD=""
	fi
	writelog "code submit[$ROLLBACK_CMD]"
	check_result "rm -rf ${RELEASE_PROJECT}/*" ${ROLLBACK_CMD}
	check_result "cp -rf ${SHELL_ROOT}/* ${RELEASE_PROJECT}" ${ROLLBACK_CMD}
	check_result "chown -R www-data.www-data ${RELEASE_PROJECT}" ${ROLLBACK_CMD}
	check_result "chown -R www-data.www-data ${RELEASE_TMP}" ${ROLLBACK_CMD}
	check_result "chown -R www-data.www-data ${RELEASE_TAR}" ${ROLLBACK_CMD}
	check_result "chown -R www-data.www-data ${RELEASE_BAKUP}" ${ROLLBACK_CMD}
	check_result "chown -R www-data.www-data ${RELEASE_LOGS}" ${ROLLBACK_CMD}
	check_result "chmod -R 775 ${RELEASE_PROJECT}" ${ROLLBACK_CMD}
	check_result "chmod -R 775 ${RELEASE_TMP}" ${ROLLBACK_CMD}
	check_result "chmod -R 775 ${RELEASE_TAR}" ${ROLLBACK_CMD}
	check_result "chmod -R 775 ${RELEASE_BAKUP}" ${ROLLBACK_CMD}
	check_result "chmod -R 775 ${RELEASE_LOGS}" ${ROLLBACK_CMD}

	if [[ -z $1 ]];then
		rm -rf ${RELEASE_TAR}/${TAG_NAME}${RELEASE_TAG_EXTENSION}${BAKUP_EXTENSION}
		writelog "delete backup tar[${RELEASE_TAR}/${TAG_NAME}${RELEASE_TAG_EXTENSION}${BAKUP_EXTENSION}]"
	fi

	su www-data -c "php ${RELEASE_PROJECT}/think clear"
	su www-data -c "php ${RELEASE_PROJECT}/think optimize:route"
	su www-data -c "php ${RELEASE_PROJECT}/think optimize:autoload"
	su www-data -c "php ${RELEASE_PROJECT}/think optimize:schema"
	su www-data -c "php ${RELEASE_PROJECT}/think optimize:config"
	su www-data -c "php ${RELEASE_PROJECT}/think refreshRoleCache"

	crontab
}

rollback_fun() {
	ROLLBACK_TAG=$1
	if [[ -f "${RELEASE_TAR}/${ROLLBACK_TAG}${RELEASE_TAG_EXTENSION}" ]];then
		writelog "rollback start..."
		tar -zxf ${PACKAGE}${RELEASE_TAG_EXTENSION} -C ${ROLLBACK_TAG}
		cd ${ROLLBACK_TAG}/${SHELL_PATH}
		code_submit
		server_restart "web"
		writelog "rollback finished."
	else
		writelog "rollback failed, [${ROLLBACK_TAG} is not exist.]"
	fi
}

rollback() {
	ROLLBACK_VER=$1
	if [[ -z ${ROLLBACK_VER} ]];then
		writelog "please input rollback version."
		usage
	else
		case ${ROLLBACK_VER} in
			list)
				cd ${RELEASE_TAR}
				ls -l *${RELEASE_TAG_EXTENSION} | awk -F ' ' '{print $NF}' | cut -d '.' -f1
				;;
			*)
				rollback_fun ${ROLLBACK_VER}
		esac
	fi
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
#backup mysql
mysql_bakup() {
	writelog "mysql bakup[$old_web_ver]..."

	writelog "backup mysql begin"

	if [[ ! -d ${RELEASE_BAKUP} ]];then
		mkdir ${RELEASE_BAKUP}
	fi
#删除/var/pbx下面bak.sql
	if [[ -f "$RELEASE_SQL_BACK" ]];then
		check_result "rm $RELEASE_SQL_BACK -rf"
	fi
#删除之前的/var/pbx/backup/下updateaicall_current.sql
	if [[ -f "$RELEASE_SQL_UPDATE" ]];then
		check_result "rm $RELEASE_SQL_UPDATE -rf"
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
	return ${SUCCESS}
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
    writelog "sub databases clean end."
	writelog "install database [$MYSQL_DATABASE] success."
	return ${SUCCESS}
}

mysql_fenku_fun() {
	fenku_file="fenku.txt"
  	if [[ ! -f "$fenku_file" ]];then
    	mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -ss -e "show databases" | grep ${MYSQL_DATABASE_FENKU} > ${fenku_file}
  	fi
  	cut_db_file ${SHELL_SQL_UPDATE_FENKU} ${old_web_ver} "$RELEASE_SQL_UPDATE_FENKU" "SET NAMES utf8;"
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
#MYSQL_DATABASE="ai"
#MYSQL_DATABASE_FENKU="aicall_0"
#--set-gtid-purged=OFF
MYSQL_DATABASE_VAIRABLE="--single-transaction --set-gtid-purged=OFF"

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
		check_result "cat $RELEASE_SQL_UPDATE"
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
	if [[ `cat ${fenku_file} | wc -l` -ne 0 ]];then
		writelog "$fenku_file is not end, please retry."
    	shell_exit ${ERROR_DEFAULT}
    else
    	writelog "$MYSQL_DATABASE_FENKU has updated."
	fi
}

redis_check() {
	redis-cli --version
	if [[ $? -ne 0 ]];then
		writelog "redis package is not installed."
		shell_exit ${ERROR_DEFAULT}
	else
		writelog "redis is exist."
	fi
}

redis_install_fun() {
	writelog "redis install fun..."
	redis_check
	#server_conf	"redis"
	server_restart "cache"
}

join() {
    if [[ -z $1 ]];then
        writelog "no join service."
        shell_exit ${ERROR_DEFAULT}
    fi
    input_check "是否开启第三方服务接入?{Y/N}" "N"

    if [[ ${input} = 'unicom' || ${input} = 'icbc' ]]; then
        writelog "准备第三方服务[${input}]接入..."
    else
        writelog "已取消第三方服务接入。"
	    return ${SUCCESS}
    fi

    su www-data -c "php ${RELEASE_PROJECT}/think join -s $1 -f applyConf"
    su www-data -c "php ${RELEASE_PROJECT}/think join -s $1 -f applySql"
    su www-data -c "php ${RELEASE_PROJECT}/think join -s $1 -f applyCron"
}

statistic() {
    writelog "准备整理统计数据，时间有点长，请稍后..."
    su www-data -c "php ${RELEASE_PROJECT}/think statistic:call_per_hour"
    writelog "统计数据整理完毕。"
}

configoc() {
    writelog "准备配置es的oc地址，请稍后..."
    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} -ss -e "UPDATE enterprise_info SET oc_ip = '$1'" 2>>${SHELL_LOG}
    if test $? -eq 0; then
        writelog "配置es的oc地址成功！"
    else
        writelog "配置es的oc地址失败！"
    fi
}

sql() {
    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE} < $1 2>>${SHELL_LOG}
}

db_bakup() {
    writelog "准备删除3天前的数据库备份..."
    find ${RELEASE_BAKUP}/${MYSQL_DATABASE}/bakup_* -type f -mtime +3 -exec rm {} \;
    writelog "3天前的数据库备份删除完毕。"

    dbname=bakup_${CDATE}.sql
    writelog "开始备份数据库:${dbname}"
    mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p"$MYSQL_PASSWORD" -R -E --single-transaction ai --ignore-table=ai.calllog --ignore-table=ai.outcall_task --ignore-table=ai.outcall_clue --ignore-table=ai.aicall_calllog_label --ignore-table=ai.emergency_contacter --ignore-table=ai.aicall_calllog_continuous_sync --ignore-table=ai.aicall_calllog_extension > ${RELEASE_BAKUP}/${MYSQL_DATABASE}/${dbname}
    writelog "数据库备份完毕：${dbname}。"
}

setValue() {
    _KEY=$1
    _OLD=`eval echo '$'"${_KEY}"`
    writelog "$_KEY $_OLD"
    SHELL_FILE="$(cd `dirname $0`; pwd)/${0##*/}"
    sed -i "s/${_KEY}=\"${_OLD}\"/${_KEY}=\"$2\"/" ${SHELL_FILE}
}

main() {
	DEPLOY_METHOD=$1
	DEPLOY_DATA=$2

	shell_is_lock "$DEPLOY_DATA"

	init

	case ${DEPLOY_METHOD} in
		init)
			writelog "server init success *^_^*"
			;;
		conf)
		 	shell_conf "$DEPLOY_DATA"
			;;
		deploy)
			server_conf "web"
			code_config
			code_tar
			code_submit
			server_restart "web"
			;;
		install)
			writelog "install>>>>>>>>>>>>>>>>"
			shell_lock
			shell_conf "$DEPLOY_DATA"
			main "mysqlinstall" "ignorelock"
			main "deploy" "ignorelock"
			shell_unlock
			writelog "install success *^_^*"
			;;
		update)
			writelog "update>>>>>>>>>>>>>>>>"
			shell_lock
			shell_conf "$DEPLOY_DATA"
			main "mysqlupdate" "ignorelock"
			main "deploy" "ignorelock"
			shell_unlock
			writelog "update success *^_^*"
			;;
		rollback)
			shell_lock
			rollback ${DEPLOY_DATA}
			shell_unlock
			;;
		mysqlconf)
			mysql_conf "${DEPLOY_DATA}"
			;;
		mysqlinstall)
			if [[ ${SERVER_MOUDLE} = "api" ]];then
			    writelog "mysql install ignore."
			    return ${SUCCESS}
			fi
			mysql_install_fun
			;;
		mysqlupdate)
			if [[ ${SERVER_MOUDLE} = "api" ]];then
			    writelog "mysql update ignore."
			    return ${SUCCESS}
			fi
			version_check "$DEPLOY_DATA"
			mysql_update_fun
			mysql_fenku_fun
			mysql_update_result
			;;
		redisinstall)
			redis_install_fun
			;;
		crontab)
			crontab
			;;
		join)
		    join ${DEPLOY_DATA}
		    ;;
		statistic)
			statistic
			;;
		configoc)
			configoc "${DEPLOY_DATA}"
			;;
		sql)
			sql "${DEPLOY_DATA}"
			;;
		bakup)
			db_bakup
			;;
		set)
			setValue ${DEPLOY_DATA} $3
			;;
		source)
			source server-init.sh ShanxiJoinService
			;;
		test)
			writelog "test"
			;;
		*)
			usage
	esac
}

main "$1" "$2" "$3"
exit ${SUCCESS}
