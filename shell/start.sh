#!/bin/bash
#启动docker容器服务
# @author HuKaijun<Hukaijun@emicnet.com>

script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
cd $EMICHOME
#初始化服务

function start_container(){
  case "$1" in
      "aicall")
      start_aiweb ${CONFIG_VERSION_AICALL}
      ;;
      "freeswitch")
      start_freeswitch ${CONFIG_VERSION_FREESWITCH}
      ;;
      "outcall_server")
      start_outcall_server ${CONFIG_VERSION_OUTCALL_SERVER}
      ;;
      "ttscache_server")
      start_ttscache_server
      ;;
      "tts_server")
      start_tts_server
      ;;
      "nlp_server")
      start_nlp_server ${CONFIG_VERSION_NLP_SERVER}
      ;;
      "redis")
      start_redis ${CONFIG_VERSION_REDIS}
      ;;
      "mysql")
      start_mysql ${CONFIG_VERSION_MYSQL}
      ;;
      *)
      echo "No this Images！！"
      ;;
  esac
}
#docker load --input导入镜像
function load() {
  image_path="$BASEHOME/images"
  log_info "load $1"
  imgName=`find $BASEHOME/images -name "$1"`
  if [ -z ${imgName} ]; then
      log_error "No images is $1"
      exit 1;
  else
      log_info "load $imgName"
      docker load --input $imgName
      log_info "load images complete"
  fi
}
#后期redis的压缩包名改成emi_redis,重做images的压缩包
function start_redis(){
    docker images |grep "redis"|grep ${CONFIG_VERSION_REDIS}
    if [[ $? -ne 0 ]];then
    load "emi_redis.${CONFIG_VERSION_REDIS}.tar"
    fi
    if [[ ! -d ${CONFIG_CONF_PATH}/redis ]];then
       mkdir ${CONFIG_CONF_PATH}/redis
       else
       echo "已经存在目录：${CONFIG_CONF_PATH}/redis"
    fi
    if [[ ! -d $logsdir/redis ]];then
       mkdir ${logsdir}/redis
       else
       echo "已经存在目录：${logsdir}/redis"
    fi
    
    log_info "[配置]:${CONFIG_CONF_PATH}/redis"
    log_info "[日志]:${logsdir}/redis"
    log_info "Starting container for redis[${CONFIG_VERSION_REDIS}]!"
    command="docker run -it -d  --restart="${CONFIG_RESTART_MODE}" --network ${CONFIG_NETWORK_MODE}  --name redis"
    command="$command -v ${CONFIG_CONF_PATH}/redis/:/etc/redis/"
    log_info  "正在执行 ${command}"
    eval ${command}
    new_container=`docker ps | grep "redis:${CONFIG_VERSION_REDIS}" | wc -l`
    if [[ ${new_container} -gt 0 ]];then
      log_info "容器启动成功"
    else
      log_info "容器启动失败，检查相关配置和日志!"
    fi   
}


function start_mysql(){
    packages=`rpm -qa|grep mysql`
    if [[ $? -eq 0 ]];then
      log_error  "请客户判断是否是系统自带的原生安装mysql.pl" 
      log_error  "想一键卸载，请输入yes"
      log_error  "保留mysql，请输入no"
      case $1 in
      yes)
      do
      for file in $packages;do
         rpm -e --nodeps $file
         yum clean all >/dev/null
      done
      ;;
      no）
      break
      ;;
      *)
      log_error "输入错误，"
    esac
    else
      log_info "该服务器没有原生mysql"
    fi
    docker images|grep "mysql"|grep ${CONFIG_VERSION_MYSQL}
    if [[ $? -ne 0 ]];then
       load "mysql.${CONFIG_VERSION_MYSQL}.tar"
    fi
    if [[ ! -d $CONFIG_CONF_PATH/mysql ]];then
      mkdir $CONFIG_CONF_PATH/mysql
    else
      echo "已经存在目录：$CONFIG_CONF_PATH/mysql"
    fi
    if [[ ! -d $logsdir/mysql ]];then
       mkdir $logsdir/mysql
    else
       echo "已经存在目录：$logsdir/mysql "
    fi
    cp $BASEHOME/src/base/mysql/my.cnf  /etc/my.cnf
    mysql_data_path="/var/pbx/lib/mysql/data"
       if [[ -d ${mysql_data_path} ]]; then
          rm ${mysql_data_path}/* -rf
       else
          mkdir ${mysql_data_path} -p
       fi
    log_info "[配置]:${CONFIG_CONF_PATH}/mysql"
    log_info "[mysql_port]:${CONFIG_MYSQL_PORT}"
    log_info "[日志]:${logsdir}/mysql"  
    log_info "Starting container for mysql[${CONFIG_VERSION_MYSQL}]!"
    command="docker run -it -d  --restart="${CONFIG_RESTART_MODE}" --network=${CONFIG_NETWORK_MODE}  --name mysql"
    command="$command --privileged=true -v  $BASEHOME/src/base/mysql/my.cnf:/etc/mysql/my.cnf "
    command="$command -v $logsdir/mysql:/var/log -v ${mysql_data_path}:/var/pbx/lib/mysql"                          
    command="$command -e TZ=Aisa/Shangha -e MYSQL_ROOT_PASSWORD=Sinicnet@123456 "
    command="$command mysql:${CONFIG_VERSION_MYSQL}"
    eval ${command}
    log_info  "正在执行 ${command}"
    new_container=`docker ps | grep "mysql:${CONFIG_VERSION_mysql}" | wc -l`
    if [[ ${new_container} -gt 0 ]];then
      log_info "容器启动成功"
    else
      log_info "容器启动失败，检查相关配置和日志!"
    fi 
    chown mysql:mysql ${mysql_data_path}
}
#启动aiweb
#docker run -it -d --restart=always -p 1171:10251 -p 1172:443  --name aicall  -v /var/pbx/upload:/var/pbx/upload -v /var/pbx/logs/aicall:/var/pbx/tmp/logs -v /etc/pbx/aicall:/var/pbx/website/config --env MYSQL_HOST=127.0.0.1  --env MYSQL_USER=emi_ai --env MYSQL_PASSWORD=Sinicnet@123456 aicall:

function start_aiweb(){

    docker images |grep "aicall"|grep ${CONFIG_VERSION_AICALL}
    if [[ $? -ne 0 ]];then
        load "aicall.${CONFIG_VERSION_AICALL}.tar"
    fi
    log_info "Starting container for aicall[${CONFIG_VERSION_AICALL}]！"
    #aiweb
    log_info "[HTTP_PORT]: AI 管理中心http端口${CONFIG_HTTP_PORT}"
    log_info "[HTTPS_PORT]:AI 管理中心https端口 ${CONFIG_HTTPS_PORT}"
    log_info "[CONFIG_MYSQL_PASSWORD]:AI 数据库密码 ${CONFIG_MYSQL_PASSWORD}"
    log_info "[CONFIG_MYSQL_PORT]:AI 数据库端口 ${CONFIG_MYSQL_PORT}"
    #执行运行脚本 it交互式 d后台运行 冒号":"前面的目录是宿主机目录，后面的目录是容器内目录
    command="docker run -it -d --network ${CONFIG_NETWORK_MODE} --restart=${CONFIG_RESTART_MODE} --name aicall "
    command="${command} -v ${resdir}:/var/pbx/upload -v ${logsdir}/aicall:/var/pbx/tmp/logs"
    command="${command} -v ${CONFIG_CONF_PATH}/aicall:/var/pbx/website/config"
    command="${command} --env MYSQL_HOST=${EMIC_MYSQL_HOST}  --env MYSQL_USER=emi_web --env MYSQL_PASSWORD=${CONFIG_MYSQL_PASSWORD}"
    command="${command} --env  HTTP_PORT=${CONFIG_HTTP_PORT}"
    command="${command} --env  HTTPS_PORT=${CONFIG_HTTPS_PORT}"
    command="${command} --env  MYSQL_PORT=${CONFIG_MYSQL_PORT}"
    if [[ ! -z ${OC_SERVER} ]];then
        command="${command} --env  OC_SERVER=${CONFIG_OUTCALL_HOST}"
    fi
    if [[ ! -z ${CONFIG_JOIN_SERVICE} ]]; then
      command="${command} --env JOIN_SERVICE=${CONFIG_JOIN_SERVICE}"
    fi
    command="${command} aicall:${CONFIG_VERSION_AICALL}"
    log_info  "正在执行 ${command}"
    eval ${command}
    sleep 3
    #MAKR::更新mysql端口
    sed -i 's/3306/'${CONFIG_MYSQL_PORT}'/' "${CONFIG_CONF_PATH}/aicall/database.php"
    log_info  "设置MYSQL端口为: ${CONFIG_MYSQL_PORT}"

    new_container=`docker ps | grep "$name" | wc -l`
    if [[ "$new_container" -gt "0" ]];then
	    log_info "容器启动成功"
	    return 1
    fi
    log_info "容器启动失败，检查相关配置和日志!"
}

function start_freeswitch(){
    docker images |grep "freeswitch"|grep ${CONFIG_VERSION_FREESWITCH}
    if [[ $? -ne 0 ]];then
        load "freeswitch.${CONFIG_VERSION_FREESWITCH}.tar"
    fi
    log_info "Starting container for freeswitch！"
    voice_path="/usr/share/freeswitch/sounds/en/us/callie"
    etc_path="${CONFIG_CONF_PATH}/freeswitch/"
    log_path="${logsdir}/freeswitch/"
    if [[ -d ${voice_path} ]];then
        log_info "目录已经存在正在删除文件[${voice_path}]"
        tar -zcvf  "${CONFIG_BAK_PATH}/callie_$(date "+%Y%m%d%H%M%S").tgz" ${voice_path}
        log_info "备份文件到[${CONFIG_BAK_PATH}]"
        rm ${voice_path} -rf
    fi
    if [[ ! -L ${voice_path} ]];then
        log_info "正在创建link[${voice_path}]"
        if [[ ! -d "/usr/share/freeswitch/sounds/en/us" ]];then
          mkdir -p "/usr/share/freeswitch/sounds/en/us"
        fi
        ln -s ${resdir} ${voice_path}
    fi
    #etc_path
    if [[ -d ${etc_path} ]];then
        log_info "已经存在配置目录[${etc_path}]"
        tar -zcvf  "${CONFIG_BAK_PATH}/freeswitch_config_$(date "+%Y%m%d%H%M%S").tgz" ${etc_path}
        log_info "备份文件到[${CONFIG_BAK_PATH}]"
    fi
    #log_path
    if [[ -d ${log_path} ]];then
        log_info "已经存在配置目录[${log_path}]"
        tar -zcvf  "${CONFIG_BAK_PATH}/freeswitch_log_$(date "+%Y%m%d%H%M%S").tgz" ${etc_path}
        log_info "备份文件到[${CONFIG_BAK_PATH}]"
    fi
    #fs
    log_info "[CONFIG_FS_HOST]:OC_SERVER ${CONFIG_OUTCALL_SERVER_HOST}"
    log_info "[CONFIG_TTS_HOST]:AI 数据库密码 ${CONFIG_TTS_HOST}"
    log_info "[CONFIG_MRCP_HOST]:AI 数据库密码 ${CONFIG_MRCP_HOST}"

    #执行脚本 docker run -it（交互方式分配终端）-d 后台运行
    command="docker run -it -d --restart=${CONFIG_RESTART_MODE}  --privileged=false --network ${CONFIG_NETWORK_MODE}  --name freeswitch "
    command="${command} -v ${CONFIG_TTSCACHE_PATH}:/data/tts_cache"
    command="${command} -v ${CONFIG_CONF_PATH}/freeswitch:/etc/freeswitch"
    command="${command} -v ${logsdir}/freeswitch:/var/log/freeswitch"
    command="${command} -v /usr/share/freeswitch/sounds/en/us/callie/:/usr/share/freeswitch/sounds/en/us/callie/"

    if [[ ! -z ${CONFIG_OUTCALL_HOST} ]];then
        command="${command} --env  OC_SERVER_IP=${CONFIG_OUTCALL_HOST}"
    fi
    if [[ ! -z ${CONFIG_FREESWITCH_HOST} ]];then
        command="${command} --env  FS_EXTEND_IP=${CONFIG_FREESWITCH_HOST}"
        command="${command} --env  FS_LOCAL_IP=${CONFIG_FREESWITCH_HOST}"
    fi
    if [[ ! -z ${CONFIG_ASR_HOST} ]];then
        command="${command} --env  MRCP_IP=${CONFIG_ASR_HOST}"
        command="${command} --env  ACL_ALLOWED_IP=${CONFIG_ASR_HOST}"
    fi
    command="${command} freeswitch:$1"
    log_info  "正在执行 ${command}"
    eval ${command}
    new_container=`docker ps | grep "$name" | wc -l`
    if [[ "$new_container" -gt "0" ]];then
	    log_info "[freeswitch]容器启动成功"
	    return 1
    fi
    log_info "容器启动失败，检查相关配置和日志!"
}
#emic nlp 安装
function start_nlp_server(){
  docker images |grep "nlp_server"|grep ${CONFIG_VERSION_NLP_SERVER}
  if [[ $? -ne 0 ]];then
      load "nlp_server.${CONFIG_VERSION_NLP_SERVER}.tar"
  fi
  log_info "Starting container for nlp_server！"
  command="docker run -it -d --restart=${CONFIG_RESTART_MODE} --network ${CONFIG_NETWORK_MODE} --name nlp_server"
  command="${command} --env MYSQL_HOST=rm-2ze4h4gd92r731iapeo.mysql.rds.aliyuncs.com  --env MYSQL_USER=emi_ai --env MYSQL_PASSWORD=Sinicnet123456"
  command="${command} --env EID=19"
  command="${command} --env ENV_STATUS=0"
  command="${command} nlp_server:$1"
  log_info  "正在执行 ${command}"
  eval ${command}
  new_container=`docker ps | grep "$name" | wc -l`
  if [[ "$new_container" -gt "0" ]];then
	    log_info "[nlp_server]容器启动成功"
	    return 1
  fi
    log_info "容器启动失败，检查相关配置和日志!"
}


#启动OC
function start_outcall_server(){
  docker images |grep "outcall_server"|grep ${CONFIG_VERSION_OUTCALL_SERVER}
  if [[ $? -ne 0 ]];then
      load "outcall_server.${CONFIG_VERSION_OUTCALL_SERVER}.tar"
  fi
  log_info "Starting container for outcall_server！"
  log_info "[TTScached目录]:${CONFIG_TTSCACHE_PATH}"
  log_info "[配置]:${CONFIG_CONF_PATH}/outcall_server"
  log_info "[日志]:${logsdir}/outcall_server"
  chmod 777 "${logsdir}/outcall_server" -R
  log_info "[REDIS_IP:REDIS_PORT]:${CONFIG_REDIS_HOST}:${CONFIG_REDIS_PORT}"

  command="docker run -it -d --restart=${CONFIG_RESTART_MODE} --network ${CONFIG_NETWORK_MODE} --name outcallserver"
  command="${command} -v ${CONFIG_CONF_PATH}/outcall_server:/home/emi/outcallserver/conf"
  command="${command} -v ${logsdir}/outcall_server:/tmp/OutcallServer"
  command="${command} -v ${logsdir}/TTSCacheServer:/tmp/TTSCacheServer"
  command="${command} -v ${CONFIG_TTSCACHE_PATH}:${CONFIG_TTSCACHE_PATH}"
  db_connet_str="host=${EMIC_MYSQL_HOST};port=${CONFIG_MYSQL_PORT};db=ai;user=emi_ai;password=${CONFIG_MYSQL_PASSWORD};compress=true;auto-reconnect=true"
  command="${command} --env 'DB_CONN_STR="${db_connet_str}"'"
  command="${command} --env REDIS_IP=${EMIC_REDIS_HOST}"
  command="${command} --env REDIS_PORT=${CONFIG_REDIS_PORT}"
  command="${command} --env REDIS_PW=${CONFIG_REDIS_PASSWORD}"
  command="${command} --env FREESWITCH_ADDRESS=${EMIC_FREESWITCH_HOST}"
  command="${command} --env FREESWITCH_INBOUND_PORT=8011 --env TTS_CACHE_SERVER_PORT=9985 "
  command="${command} --env TTS_CACHE_SERVER_IP=127.0.0.1"
  tts_server_url="http://tts.emic:${CONFIG_TTS_PORT}/tts"
  command="${command} --env TTS_SERVER_URL=${tts_server_url}"
  command="${command} --env TTS_CACHE_LOCAL_PATH=${CONFIG_TTSCACHE_PATH}"
  web_api_host="https://${EMIC_AICALL_HOST}:${CONFIG_HTTPS_PORT}"
  command="${command} --env TTS_CACHE_SERVER_START=0 --env 'WEB_API_HOST="${web_api_host}"'"
  command="${command} outcall_server:$1"


  
    log_info  "正在执行 ${command}"
    eval ${command}
    sleep 5
    sed -i "s/\"${db_connet_str}\"/${db_connet_str}/g" "${CONFIG_CONF_PATH}/outcall_server/callingrobot.config"
    log_info  "更新配置数据库链接为:${db_connet_str}"
    new_container=`docker ps | grep "$name" | wc -l`
    if [[ "$new_container" -gt "0" ]];then
	    log_info "[outcall_server]容器启动成功"
	    return 1
    fi
    log_info "容器启动失败，检查相关配置和日志!"
}

function start_ttscache_server()
{
  log_info "正在安装ttscache_server"
}


function start_tts_server()
{
    start_script_path="${CONFIG_SCRIPT_PATH}/tts_start.sh"
    if [[ ! -f ${start_script_path} ]]; then
         log_error "尚未配置TTS-server，请手动启动"
         exit 1
    fi
    chmod +x $start_script_path;
    log_info "正在执行[$start_script_path]"
    sh ${start_script_path} &>/dev/null
}

function main() {
    #初始化配置
    cat << EOF
+-------------------------------------------------+
|                启动Docker容器                |
+-------------------------------------------------+

            ---即将启动Docker的容器---
EOF
    if [[ -z $@ ]]; then
    cat << EOF
      [aicall]              web提供界面
      [outcall_server]      外呼服务 任务管理
      [freeswitch]          Freeswitch服务
      [tts-server]                 TTS服务
      [no_match_server]     未匹配话术学习
EOF
    else
        for contain in $@;do
cat << EOF
      [$contain]              AI服务组件
EOF
        done
    fi
echo "+-------------------------------------------------+"
    #启动容器服务；-z $@，参数为空时 -z 长度为空则为真
    if [[ -z $@ ]]; then
      start_container aicall
      start_container freeswitch
      start_container outcall_server
    else
      for contain in $@;do
        start_container $contain
      done
    fi
    #查看容器状态
}

main $@


