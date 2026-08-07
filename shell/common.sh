#!/bin/bash
#AI系统脚本公共库
# @author HuKaijun<Hukaijun@emicnet.com>

EMICHOME=$(cd `dirname $0`; pwd)
BASEHOME=$(cd ${EMICHOME}/..; pwd)
EMIC_VERSION="2.0"
MSGFILE=$BASEHOME/.msg
CONFIGFILE="${BASEHOME}/conf/emic_ai.conf"
#Default host for emic ai
EMIC_ASR_HOST=asr.emic
EMIC_FREESWITCH_HOST=freeswitch.emic
EMIC_OUTCALL_HOST=outcall.emic
EMIC_AICALL_HOST=aicall.emic
EMIC_MYSQL_HOST=mysql.emic
EMIC_REDIS_HOST=redis.emic
EMIC_TTS_HOST=tts.emic

cd $BASEHOME
#读取配置
#echo  "...初始化配置[$CONFIGFILE]"
CONFIG_REDIS_HOST=`cat $CONFIGFILE | grep "^redis_server_host" | sed "s/redis_server_host=//g" | tr -d "\r\n"`
CONFIG_MYSQL_HOST=`cat $CONFIGFILE | grep "^mysql_server_host" | sed "s/mysql_server_host=//g" | tr -d "\r\n"`
CONFIG_FREESWITCH_HOST=`cat $CONFIGFILE | grep "^freeswitch_server_host" | sed "s/freeswitch_server_host=//g" | tr -d "\r\n"`
CONFIG_OUTCALL_HOST=`cat $CONFIGFILE | grep "^outcall_server_host" | sed "s/outcall_server_host=//g" | tr -d "\r\n"`
CONFIG_AICALL_HOST=`cat $CONFIGFILE | grep "^aicall_server_host" | sed "s/aicall_server_host=//g" | tr -d "\r\n"`
CONFIG_TTS_HOST=`cat $CONFIGFILE | grep "^tts_server_host" | sed "s/tts_server_host=//g" | tr -d "\r\n"`
CONFIG_ASR_HOST=`cat $CONFIGFILE | grep "^asr_server_host" | sed "s/asr_server_host=//g" | tr -d "\r\n"`
CONFIG_ENV_MODEL=`cat $CONFIGFILE | grep "^env_model" | sed "s/env_model=//g" | tr -d "\r\n"`
CONFIG_VERSION_REDIS_SERVER=`cat $CONFIGFILE | grep "^version_redis" | sed "s/version_redis=//g" | tr -d "\r\n"`
CONFIG_VERSION_MYSQL_SERVER=`cat $CONFIGFILE | grep "^version_mysql" | sed "s/version_mysql=//g" | tr -d "\r\n"`

CONFIG_VERSION_NLP_SERVER=`cat $CONFIGFILE | grep "^version_nlp" | sed "s/version_nlp=//g" | tr -d "\r\n"`
CONFIG_NLP_PORT=`cat $CONFIGFILE | grep "^nlp_port" | sed "s/nlp_port=//g" | tr -d "\r\n"`

logsdir=`cat $CONFIGFILE | grep "^host_logs_dir" | sed "s/host_logs_dir=//g" | tr -d "\r\n"`
diskdir=`cat $CONFIGFILE | grep "^host_disk_dir" | sed "s/host_disk_dir=//g" | tr -d "\r\n"`
resdir=`cat $CONFIGFILE | grep "^host_res_dir" | sed "s/host_res_dir=//g" | tr -d "\r\n"`
run_uid=`cat $CONFIGFILE | grep "^run_uid" | sed "s/run_uid=//g" | tr -d "\r\n"`
CONFIG_BAK_PATH="${diskdir}/tmp"
CONFIG_TTSCACHE_PATH=`cat $CONFIGFILE | grep "^host_ttscache_dir" | sed "s/host_ttscache_dir=//g" | tr -d "\r\n"`
CONFIG_CRONTAB_PATH=`cat $CONFIGFILE | grep "^crontab_path" | sed "s/crontab_path=//g" | tr -d "\r\n"`
CONFIG_SCRIPT_PATH=`cat $CONFIGFILE | grep "^script_path" | sed "s/script_path=//g" | tr -d "\r\n"`

#REDIS
CONFIG_REDIS_PASSWORD=`cat $CONFIGFILE | grep "^redis_passwd" | sed "s/redis_passwd=//g" | tr -d "\r\n"`
CONFIG_REDIS_PORT=`cat $CONFIGFILE | grep "^redis_port" | sed "s/redis_port=//g" | tr -d "\r\n"`
CONFIG_VERSION_REDIS=`cat $CONFIGFILE | grep "^version_redis" | sed "s/version_redis=//g" | tr -d "\r\n"`
#MYSQL
CONFIG_VERSION_MYSQL=`cat $CONFIGFILE | grep "^version_mysql" | sed "s/version_mysql=//g" | tr -d "\r\n\[A-Z]"`

#数据库
CONFIG_VERSION_DATA=`cat $CONFIGFILE | grep "^version_data" | sed "s/version_data=//g" | tr -d "\r\n"`
#
CONFIG_MYSQL_PASSWORD=`cat $CONFIGFILE | grep "^mysql_password" | sed "s/mysql_password=//g" | tr -d "\r\n"`
CONFIG_MYSQL_PORT=`cat $CONFIGFILE | grep "^mysql_port" | sed "s/mysql_port=//g" | tr -d "\r\n"`
#docker 运行模式
CONFIG_RESTART_MODE=`cat $CONFIGFILE | grep "^restart_mode" | sed "s/restart_mode=//g" | tr -d "\r\n"`
CONFIG_NETWORK_MODE=`cat $CONFIGFILE | grep "^network_mode" | sed "s/network_mode=//g" | tr -d "\r\n"`
#TTS
CONFIG_TTS_NUM=`cat $CONFIGFILE | grep "^tts_num" | sed "s/tts_num=//g" | tr -d "\r\n"`
CONFIG_TTS_PORT=`cat $CONFIGFILE | grep "^tts_port" | sed "s/tts_port=//g" | tr -d "\r\n"`
CONFIG_TTS_TYPE=`cat $CONFIGFILE | grep "^tts_type" | sed "s/tts_type=//g" | tr -d "\r\n"`
#freeswitch
CONFIG_VERSION_FREESWITCH=`cat $CONFIGFILE | grep "^version_freeswitch" | sed "s/version_freeswitch=//g" | tr -d "\r\n"`
CONFIG_FS_HOST=`cat $CONFIGFILE | grep "^freeswitch_host" | sed "s/freeswitch_host=//g" | tr -d "\r\n"`
CONFIG_FS_PORT=`cat $CONFIGFILE | grep "^fs_port" | sed "s/fs_port=//g" | tr -d "\r\n"`
CONFIG_OC_HOST=`cat $CONFIGFILE | grep "^oc_host" | sed "s/oc_host=//g" | tr -d "\r\n"`
CONFIG_MRCP_HOST=`cat $CONFIGFILE | grep "^mrcp_host" | sed "s/mrcp_host=//g" | tr -d "\r\n"`
CONFIG_CONF_PATH=`cat $CONFIGFILE | grep "^conf_path" | sed "s/conf_path=//g" | tr -d "\r\n"`
#outcall_server
CONFIG_VERSION_OUTCALL_SERVER=`cat $CONFIGFILE | grep "^version_outcall_server" | sed "s/version_outcall_server=//g" | tr -d "\r\n"`
CONFIG_WEB_API=`cat $CONFIGFILE | grep "^web_api_host" | sed "s/web_api_host=//g" | tr -d "\r\n"`
#aicall
CONFIG_VERSION_AICALL=`cat $CONFIGFILE | grep "^version_aicall" | sed "s/version_aicall=//g" | tr -d "\r\n"`
CONFIG_HTTP_PORT=`cat $CONFIGFILE | grep "^http_port" | sed "s/http_port=//g" | tr -d "\r\n"`
CONFIG_HTTPS_PORT=`cat $CONFIGFILE | grep "^https_port" | sed "s/https_port=//g" | tr -d "\r\n"`
CONFIG_JOIN_SERVICE=`cat $CONFIGFILE | grep "^join_service" | sed "s/join_service=//g" | tr -d "\r\n"`
CONFIG_OC_SERVER=`cat $CONFIGFILE | grep "^oc_server" | sed "s/oc_server=//g" | tr -d "\r\n"`
#echo  "...初始化项目目录[$diskdir]"
if [[ ! -d $diskdir ]]; then
    log_info "正在初始化应用目录[${diskdir}]"
    mkdir -p ${diskdir}
fi
#echo  "...初始化日志目录[$logsdir]"
if [[ ! -d $logsdir ]]; then
    log_info "正在初始化日志目录[${logsdir}]"
    mkdir -p ${logsdir}
    chmod 777 ${logsdir} -R
fi
# 配置CONFIG_CONF_PATH
if [[ ! -d $CONFIG_CONF_PATH ]]; then
    log_info "正在初始化配置目录[${CONFIG_CONF_PATH}]"
    mkdir -p ${CONFIG_CONF_PATH}
fi
# 备份目录
if [[ ! -d $CONFIG_BAK_PATH ]]; then
    log_info "正在初始化备份目录[${CONFIG_BAK_PATH}]"
    mkdir -p ${CONFIG_BAK_PATH}
fi

EMICLOGDIR=$(cd $logsdir; pwd)
EMICDATADIR=$(cd $diskdir; pwd)

#管理器日志
ManagerLogFile=${EMICLOGDIR}/manager.log

echo "`date`===========>[$0 $@]" >> $ManagerLogFile

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
    echo "[ERROR] $@"  >> $ManagerLogFile
}

function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
    echo "[INFO] $@"  >> $ManagerLogFile
}

function log_warn() {
    echo -e "\033[33m [WARN] $@ \033[0m"
    echo "[WARN] $@"  >> $ManagerLogFile
}


