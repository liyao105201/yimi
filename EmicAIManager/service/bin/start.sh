#!/bin/bash
#启动docker容器服务
# @author HuKaijun<Hukaijun@emicnet.com>
# docker run的步骤简介在start_redis里有部分介绍
#
#set -x

script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
cd ${EMICHOME}
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
      "elasticsearch")
      start_elasticsearch $CONFIG_VERSION_ELASTICSEARCH;;
      "spring")
      start_spring $CONFIF_VERSION_SPRING;;
      *)
      echo "No this Images！！"
      ;;
  esac
}

#docker load --input导入镜像
  image_path="$BASEHOME/images"
function load() {

  image_version=$2
  image_name=$1
  log_info "check images $image_name:$image_version"
  docker images |grep $image_name|grep $image_version
  if [[ $? -ne 0 ]];then
    log_warn "need load images"
  fi
  log_info "check pack images[${BASEHOME}/images]!"
  image_pack=${image_name}.${image_version}.tar
  imgName=`find ${BASEHOME}/images -name $image_pack`
  if [[ -z ${imgName} ]]; then
      log_error "No images is location image source hub $1"
      exit 1;
  else
      log_info "load $imgName"
      docker load --input ${imgName}
      log_info "load images complete"
  fi
}

function start_elasticsearch(){
    confElasticsearch_path=$CONFIG_CONF_PATH/java/elasticsearch/
    docker images |grep "elasticsearch"|grep $CONFIG_VERSION_ELASTICSEARCH
    if [[ $? -ne 0 ]];then
      load "analysis-elasticsearch.$CONFIG_VERSION_ELASTICSEARCH.tar"
    fi
    docker images|grep analysis-elasticsearch&&docker images|grep ai-analysis
    if [[ $? -eq 0 ]];then
      /bin/bash ./run.sh  initPathAndConf
      /bin/bash ./run.sh  startElasticsearchHostMode
      if [[ ! -e $confElasticsearch_path ]];then
      /bin/bash ./run.sh confElasticsearch
      fi
      /bin/bash ./run.sh  startAnalysisHostMode
    fi
}

function start_spring(){
    confElasticsearch_path=$CONFIG_CONF_PATH/java/elasticsearch/
    docker images |grep "ai-analysis"|grep $CONFIF_VERSION_SPRING
    if [[ $? -ne 0 ]];then
    load "ai-analysis.$CONFIF_VERSION_SPRING.tar"
    fi
    docker images|grep analysis-elasticsearch&&docker images|grep ai-analysis
    if [[ $? -eq 0 ]];then
      /bin/bash ./run.sh initPathAndConf
      /bin/bash ./run.sh startElasticsearchHostMode
      if [[ ! -e $confElasticsearch_path ]];then
        /bin/bash ./run.sh confElasticsearch
      fi
      /bin/bash ./run.sh startAnalysisHostMode
    fi   
}

#V3--新增
function start_redis(){
    docker images |grep "redis"|grep ${CONFIG_VERSION_REDIS}
    if [[ $? -ne 0 ]];then
    load "emic-ai-redis.${CONFIG_VERSION_REDIS}.tar"
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
  #docker run时先-v 将宿主机的/etc/pbx/redis文件夹挂载到容器的/etc/redis中。然后ENTRYPOINT将redis.conf复制到了容器的/etc/redis
  #docker在run后 倒数第2步执行ENTRYPOINT。倒数第一步执行cmd，cmd也可以不执行，如果docker run结束以后加了 执行程序 例如 /bin/bash
    log_info "[配置]:${CONFIG_CONF_PATH}/redis"
    log_info "[日志]:${logsdir}/redis"
    log_info "Starting container for emic-ai-redis[${CONFIG_VERSION_REDIS}]!"
    command="docker run -it -d  --restart="${CONFIG_RESTART_MODE}" --network=${CONFIG_NETWORK_MODE}  --name emic-ai-redis"
    command="$command -v ${CONFIG_CONF_PATH}/redis/:/etc/redis/ "
    command="$command -e REDIS_PORT=$CONFIG_REDIS_PORT -e REDIS_REQUIREPASS=$CONFIG_REDIS_PASSWORD"          
    command="$command emic-ai-redis:${CONFIG_VERSION_REDIS} "
    log_info  "正在执行 ${command}"
    eval ${command}
    new_container=`docker ps | grep emic-ai-redis|grep "${CONFIG_VERSION_REDIS}" | wc -l`
    if [[ ${new_container} -gt 0 ]];then
      log_info "容器启动成功"
    else
      log_info "容器启动失败，检查相关配置和日志!"
    fi   
}

#V3--新增
function start_mysql(){
    #docker run -d --name emic-ai-mysql --restart=unless-stopped --network=host -v /etc/pbx/emic_mysql/mysql_5.7.38:/etc/mysql/conf.d -v /var/pbx/lib/emic_mysql/mysql_5.7.38/mysql:/var/lib/mysql -v /var/pbx/logs/mysql:/var/log/mysql -e MYSQL_ROOT_PASSWORD=Sinicnet@123456  mysql:5.7.38 --character-set-server=utf8 --collation-server=utf8_unicode_ci
    #运行中需要手动处理
    config_mysql_path="${CONFIG_MYSQL_CONF_PATH}/mysql_${CONFIG_MYSQL_VERSION}"
    lib_mysql_path="${CONFIG_MYSQL_LIB_PATH}/mysql_${CONFIG_MYSQL_VERSION}"
    echo "Lib path is :${lib_mysql_path}"
    docker ps |grep "emic-ai-mysql"
    if [[ $? -eq 0 ]];then
      echo  "MySQL was already installed,please check you server!If you want update please use update.sh"
      exit 1
    fi
    docker images |grep "mysql"|grep ${CONFIG_MYSQL_VERSION}
    if [[ $? -ne 0 ]];then
      load "mysql.${CONFIG_MYSQL_VERSION}.tar"
    fi
    log_info "check [${lib_mysql_path}] !"
    if [[ -d ${lib_mysql_path} ]];then
      log_info "[${lib_mysql_path}] already existed"
      exit 1
      #已经安装过了该版本
      if [[ -d ${lib_mysql_path}/mysql ]];then
          log_info "[${lib_mysql_path}/mysql] already existed"
          #mv ${CONFIG_MYSQL_LIB_PATH}/mysql ${CONFIG_MYSQL_LIB_PATH}/mysql_".bak"$(date "+%Y%m%H")
      fi
    fi
    #开始安装
    #备份老的配置
    if [[ -d ${config_mysql_path} ]];then
      mv  ${config_mysql_path}/my.cnf  ${config_mysql_path}/my.cnf_".bak"$(date "+%Y%m%H")
      log_error "[${config_mysql_path}] config file already existed"
      cp ${CONFIG_MYSQL_RESOURCE_PATH}/my.cnf ${config_mysql_path}/my.cnf
    fi
#数据准备
    log_info "Starting container for mysql！"
    command="docker run -d --name emic-ai-mysql --restart=unless-stopped --network=host"
    command="${command} -v ${config_mysql_path}:/etc/mysql/conf.d"
    command="${command} -v ${lib_mysql_path}/mysql:/var/lib/mysql"
    command="${command} -v /var/pbx/logs/mysql:/var/log/mysql"
    #@MARK:下行mysql设置不生效
    command="${command} -e MYSQL_ROOT_PASSWORD=${CONFIG_MYSQL_PASSWORD}"
    command="${command}  mysql:${CONFIG_MYSQL_VERSION} --character-set-server=utf8 --collation-server=utf8_unicode_ci"
    log_info  "正在执行 ${command}"
    eval ${command}
    log_info  "正在配置Mysql"
    setting_mysql
}

function setting_mysql() {
    MYSQL_DATA_PATH="${BASEHOME}/data/base/mysql"
    MYSQL_RESOURCE_PATH="${BASEHOME}/src/base/mysql"
    MYSQL_HOME_PATH="/tmp/mysql/"
    #配置
    log_info "正在初始化容器[emic-ai-mysql]"
    complete_flag=true
    while ${complete_flag}
    do
      docker ps |grep "emic-ai-mysql"
      if [[ $? -eq 0 ]];then
        log_info "容器["emic-ai-mysql"]初始化成功"
        complete_flag=false
      fi
      sleep 1
    done
    log_info "配置mysql[${config_mysql_path}/my.cnf]"
    if [[ -f ${config_mysql_path}/my.cnf  ]];then
        log_info "mysql config is exsisted!"
        mv ${config_mysql_path}/my.cnf /tmp/my.cnf.bak_$(date "+%Y%m%H")
    fi
    if [[ ! -d ${config_mysql_path} ]];then
        mkdir -p  ${config_mysql_path}
    fi
    cp ${MYSQL_DATA_PATH}/my.cnf ${config_mysql_path}/my.cnf
    sleep 20
    docker restart emic-ai-mysql
    if [[ $? -ne 0 ]];then
        log_error "mysql restart failed!"
    fi
    #直到服务器启动完成
    complete_flag=true
    b=""
    printf "waiting mysql server:\r"
    while ${complete_flag}
    do
      netstat -nap|grep 13306 |grep -v grep
      if [[ $? -eq 0 ]];then
        log_info "容器[emic-ai-mysql]初始化成功"
        complete_flag=false
      fi
      echo -ne "[$b]"
      b+='*'
      sleep 2
    done
    #init user and database name
    log_info "正在初始化数据[${MYSQL_DATA_PATH}/mysql-ai/init_emic.sql]"
    command="docker exec -i emic-ai-mysql sh -c 'exec mysql -uroot -p\"'${CONFIG_MYSQL_PASSWORD}'\"' < ${MYSQL_DATA_PATH}/mysql-ai/init_emic.sql"
    log_info  "正在执行 ${command}"
    eval ${command}
    #docker exec -i emic-ai-mysql sh -c 'exec mysql -uroot -p"'+${CONFIG_MYSQL_PASSWORD}+'"' < ${MYSQL_DATA_PATH}/mysql-ai/init_emic.sql
    if [[ $? -ne 0 ]];then
        log_error "mysql init failed!"
        exit 0
    fi
    log_info "正在导入数据[mysql_${CONFIG_VERSION_DATA}.tar.gz]"
    if [[ -d  /tmp/mysql_${CONFIG_VERSION_DATA} ]];then
      echo "目录已经存在正在删除文件"
      rm /tmp/mysql_${CONFIG_VERSION_DATA} -rf
    fi
    mkdir  /tmp/mysql_${CONFIG_VERSION_DATA}
    data_res=${MYSQL_DATA_PATH}/mysql-ai/mysql_${CONFIG_VERSION_DATA}.tar.gz
    if [[ ! -f ${data_res} ]]; then
        log_error "mysql data [$data_res] is not find!"
        exit
    fi
    tar -zxvf ${MYSQL_DATA_PATH}/mysql-ai/mysql_${CONFIG_VERSION_DATA}.tar.gz -C /tmp/mysql_${CONFIG_VERSION_DATA}/
    docker cp /tmp/mysql_${CONFIG_VERSION_DATA}/mysql emic-ai-mysql:/
    docker exec -i emic-ai-mysql sh -c 'exec mysql -uroot -p"'${CONFIG_MYSQL_PASSWORD}'" -e  "use ai; source /mysql/add_table.sql;"'
    echo  "data init success!"
    log_info "database table init success!"
    #初始化回调
    command="docker exec -i emic-ai-mysql sh -c 'exec mysql -uroot -p\"'${CONFIG_MYSQL_PASSWORD}'\"' < ${MYSQL_DATA_PATH}/mysql-ai/complete_init.sql"
    log_info  "正在执行初始化回调 ${command}"
    eval ${command}
}


#启动aiweb
#docker run -it -d --restart=always -p 1171:10251 -p 1172:443  --name aicall  -v /var/pbx/upload:/var/pbx/upload -v /var/pbx/logs/aicall:/var/pbx/tmp/logs -v /etc/pbx/aicall:/var/pbx/website/config --env MYSQL_HOST=127.0.0.1  --env MYSQL_USER=emi_ai --env MYSQL_PASSWORD=Sinicnet@123456 aicall:

function start_aiweb(){

    TAG_NAME='emic-ai-web'
    docker images |grep "${TAG_NAME}" |grep ${CONFIG_VERSION_AICALL}
    if [[ $? -ne 0 ]];then
        load "${TAG_NAME}.${CONFIG_VERSION_AICALL}.tar"
    fi
    log_info "Starting container for emic-ai-web[${CONFIG_VERSION_AICALL}]！"
    #aiweb
    log_info "[HTTP_PORT]: AI 管理中心http端口${CONFIG_HTTP_PORT}"
    log_info "[HTTPS_PORT]:AI 管理中心https端口 ${CONFIG_HTTPS_PORT}"
    log_info "[CONFIG_MYSQL_PASSWORD]:AI 数据库密码 ${CONFIG_MYSQL_PASSWORD}"
    log_info "[CONFIG_MYSQL_PORT]:AI 数据库端口 ${CONFIG_MYSQL_PORT}"
    #执行运行脚本 it交互式 d后台运行 冒号":"前面的目录是宿主机目录，后面的目录是容器内目录
    command="docker run -it -d --network ${CONFIG_NETWORK_MODE} --restart=${CONFIG_RESTART_MODE} --name ${TAG_NAME} "
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
    command="${command} ${TAG_NAME}:${CONFIG_VERSION_AICALL} "
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
    docker images |grep "emic-ai-freeswitch"|grep ${CONFIG_VERSION_FREESWITCH}
    if [[ $? -ne 0 ]];then
        load "emic-ai-freeswitch.${CONFIG_VERSION_FREESWITCH}.tar"
    fi
    log_info "Starting container for emic-ai-freeswitch！"
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
    command="docker run -it -d --restart=${CONFIG_RESTART_MODE}  --privileged=false --network ${CONFIG_NETWORK_MODE}  --name emic-ai-freeswitch "
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
    command="${command} emic-ai-freeswitch:$1"
    log_info  "正在执行 ${command}"
    eval ${command}
    new_container=`docker ps | grep "$name" | wc -l`
    if [[ "$new_container" -gt "0" ]];then
	    log_info "[emic-ai-freeswitch]容器启动成功"
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
  command="docker run -it -d --restart=${CONFIG_RESTART_MODE} --network ${CONFIG_NETWORK_MODE} --name emic-ai-nlp"
  command="${command} --env MYSQL_HOST=${EMIC_MYSQL_HOST}  --env MYSQL_USER=emi_ai --env MYSQL_PASSWORD=${CONFIG_MYSQL_PASSWORD}"
  command="${command} --env EID=19"
  command="${command} --env ENV_STATUS=0"
  command="${command} emic_ai/nlp_server:$1"
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
  docker images |grep "emic-ai-outcallserver"|grep ${CONFIG_VERSION_OUTCALL_SERVER}
  if [[ $? -ne 0 ]];then
      load "emic-ai-outcallserver.${CONFIG_VERSION_OUTCALL_SERVER}.tar"
  fi
  log_info "Starting container for emic-ai-outcallserver！"
  log_info "[TTScached目录]:${CONFIG_TTSCACHE_PATH}"
  log_info "[配置]:${CONFIG_CONF_PATH}/outcall_server"
  log_info "[日志]:${logsdir}/outcall_server"
  chmod 777 "${logsdir}/outcall_server" -R
  log_info "[REDIS_IP:REDIS_PORT]:${CONFIG_REDIS_HOST}:${CONFIG_REDIS_PORT}"

  command="docker run -it -d --restart=${CONFIG_RESTART_MODE} --network ${CONFIG_NETWORK_MODE} --name emic-ai-outcallserver"
  command="${command} -v ${CONFIG_CONF_PATH}/outcall_server:/home/emi/outcallserver/conf"
  command="${command} -v ${logsdir}/outcall_server:/tmp/OutcallServer"
  command="${command} -v ${logsdir}/TTSCacheServer:/tmp/TTSCacheServer"
  command="${command} -v ${CONFIG_TTSCACHE_PATH}:${CONFIG_TTSCACHE_PATH}"
  db_connect_str="host=${EMIC_MYSQL_HOST};port=${CONFIG_MYSQL_PORT};db=ai;user=emi_ai;password=${CONFIG_MYSQL_PASSWORD};compress=true;auto-reconnect=true"
  command="${command} --env 'DB_CONN_STR="${db_connect_str}"'"
  command="${command} --env REDIS_IP=${EMIC_REDIS_HOST}"
  command="${command} --env REDIS_PORT=${CONFIG_REDIS_PORT}"
  command="${command} --env REDIS_PW=${CONFIG_REDIS_PASSWORD}"
  command="${command} --env FREESWITCH_ADDRESS=${EMIC_FREESWITCH_HOST}"
  command="${command} --env FREESWITCH_INBOUND_PORT=8011 --env TTS_CACHE_SERVER_PORT=9985 "
  command="${command} --env TTS_CACHE_SERVER_IP=127.0.0.1"
  tts_server_url="http://tts.emic:${CONFIG_TTS_PORT}/stream/v1/tts"
  command="${command} --env TTS_SERVER_URL=${tts_server_url}"
  command="${command} --env TTS_CACHE_LOCAL_PATH=${CONFIG_TTSCACHE_PATH}"
  command="${command} --env CONFIG_OUTCALL_SERVER_HOST=${CONFIG_OUTCALL_SERVER_HOST}"
  web_api_host="https://${EMIC_AICALL_HOST}:${CONFIG_HTTPS_PORT}"
  command="${command} --env CONFIG_NUM_TTS=${CONFIG_NUM_TTS}"
  command="${command} --env TTS_CACHE_SERVER_START=0 --env 'WEB_API_HOST="${web_api_host}"'"
  command="${command} emic-ai-outcallserver:$1"
    log_info  "正在执行 ${command}"
    eval ${command}
    sleep 5
    # sed -i "s/\"${db_connet_str}\"/${db_connet_str}/g" "${CONFIG_CONF_PATH}/outcall_server/callingrobot.config"
    # log_info  "更新配置数据库链接为:${db_connet_str}"
    new_container=`docker ps | grep "$name" | wc -l`
    if [[ "$new_container" -gt "0" ]];then
	    log_info "[outcall_server]容器启动成功"
	    return 1
    fi
    log_info "容器启动失败，检查相关配置和日志!"
}

# **下版本移除

function start_ttscache_server()
{
  log_info "正在安装ttscache_server"
}

# **下版本移除

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
      [tts-server]          **TTS服务(目前不提倡)
      [no_match_server]     未匹配话术学习
      [analysis]            智能质检服务
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
}

main $@


