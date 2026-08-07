#!/bin/bash
# 环境初始化
# 提供了mysql的安装 redis的安装 docker安装的脚本
# 支持集群环境 分布式部署，具体参考部署文档。
# 本地化部署暂不支持集群部署

# @author HuKaijun<Hukaijun@emicnet.com>

source ./common.sh

#################################
##-----初始化redis环境----------##
#################################


function env_redis() {
    case "$1" in
    "init")
        log_info "Intall redis-server[2.8.17] start!"
        REDIS_RESOURCE_PATH="${BASEHOME}/src/base/redis/"
        REDIS_HOME_PATH="/usr/local/redis"
        REDIS_TAR_FILE=`find $REDIS_RESOURCE_PATH -name *.tar.gz`
        #redis install
        if [[ ! -f ${REDIS_TAR_FILE} ]];then
            echo  "当前目录没有redis安装文件包，请检查目录"
            exit 1
        fi
        if [[ ! -d $REDIS_HOME_PATH ]];then
            mkdir -p  $REDIS_HOME_PATH
        fi
        tar -zxvf $REDIS_TAR_FILE -C $REDIS_HOME_PATH
        #建立链接
        ln -s "${REDIS_HOME_PATH}/redis-server/redis.conf" /etc/redis.conf
        ln -s "${REDIS_HOME_PATH}/redis-server/redis-server" /usr/bin/redis-server
        ln -s "${REDIS_HOME_PATH}/redis-src/src/redis-cli" /usr/bin/redis-cli
        cp "${REDIS_RESOURCE_PATH}/redis.service" /usr/lib/systemd/system/redis.service
        redis_sys_config
        log_info "正在启动Redis"
        systemctl start redis
        log_info "Test [ps -ef |grep redis-server|grep 16379 ] "
        redis_pid=`ps -ef | grep redis|grep ${CONFIG_REDIS_PORT} | grep -v grep |awk '{print $2}'`
        if [[ -z $redis_pid ]]; then
            echo "redis start failed,please check config [/etc/redis.conf]"
            log_warn "redis start failed!"
        fi
       ;;
    "clearup")
        redis-cli -h localhost -p ${CONFIG_REDIS_PORT} -a ${CONFIG_REDIS_PASSWORD} flushall
        if [[ $? -ne 0 ]];then
            log_warn "redis flushall failed!"
        fi
        ;;
     "check")
        log_warn "redis check OK!"
     ;;
    esac
}

function redis_sys_config() {
        log_info "正在配置启动项"
        sed -i "s/^port .*/port ${CONFIG_REDIS_PORT}/g" /etc/redis.conf
        sed -i "s/^#requirepass .*/requirepass ${CONFIG_REDIS_PASSWORD}/g" /etc/redis.conf
        sed -i "s/^requirepass .*/requirepass ${CONFIG_REDIS_PASSWORD}/g" /etc/redis.conf
        sed -i "s/^daemonize .*/daemonize yes/g" /etc/redis.conf
        sed -i "s/^pidfile .*/pidfile /var/run/redis.pid/g" /etc/redis.conf
        systemctl enable redis.service
        systemctl daemon-reload
}

#################################
##-----初始化mysql环境----------##
#################################

function env_mysql() {
   case "$1" in
    "init")
        log_info "Start install Mysql-server5.7!"
        MYSQL_DATA_PATH="${BASEHOME}/data/mysql-ai/"
        MYSQL_RESOURCE_PATH="${BASEHOME}/src/base/mysql/"
        MYSQL_HOME_PATH="/tmp/mysql/"
        if [[ ! -d ${MYSQL_HOME_PATH} ]]; then
            mkdir -p ${MYSQL_HOME_PATH}
        fi
        MYSQL_TAR_FILE=`find $MYSQL_RESOURCE_PATH -name 'mysql-5.7*.tar'`
        tar -xvf $MYSQL_TAR_FILE -C ${MYSQL_HOME_PATH}
        if [[ $? -ne 0 ]]; then
            log_error "解压MYDQL失败，请检查[$MYSQL_RESOURCE_PATH]是否存在[mysql安装文件]"
            exit 1
        fi
       current_dir=`pwd`
       cd $MYSQL_HOME_PATH
       log_info "正在卸载默认的mariadb"
       yum -y remove mariadb*
       log_info "正在安装依赖包perl"
       mysql_log_path="/var/log/mysqld.log"
       if [[ -f ${mysql_log_path} ]];then
          echo "" > ${mysql_log_path}
       fi
       yum install -y ${BASEHOME}/src/base/perl/*.rpm
       rm -f mysql-community-test*rpm
       yum install -y mysql*.rpm
       if [[ $? -ne 0 ]]; then
         log_error "MySQL安装失败:$?"
         exit 1
       fi
       log_info "正在配置MySQL"
       cp ${MYSQL_RESOURCE_PATH}/my.cnf  /etc/my.cnf
       mysql_data_path="/var/pbx/lib/mysql"
       if [[ -d ${mysql_data_path} ]]; then
          rm ${mysql_data_path}/* -rf
       else
          mkdir ${mysql_data_path} -p
       fi
       chown mysql:mysql ${mysql_data_path}
       mysql_init_user
       mysql_init_tables
       mysql_init_complete
       log_info "正在清理安装临时文件"
       rm -rf ${MYSQL_HOME_PATH}
       #切换回原来目录
       cd ${current_dir}
       log_info "Mysql install Success!"
    ;;
    #清空数据库
    "check")
        log_info "正在检查MYSQL所需要的环境-----[OK]"
        ;;
    esac
}

function mysql_init_complete() {
    log_info "正在配置MySQL完成选项"
    complete_sql="${MYSQL_DATA_PATH}/complete_init.sql"
    sed -i "s/outcall.emic/${CONFIG_OUTCALL_HOST}/g" ${complete_sql}
    sed -i "s/tts.emic/${CONFIG_TTS_HOST}/g" ${complete_sql}
    sed -i "s/version_aicall_db/${CONFIG_VERSION_DATA}/g" ${complete_sql}
    mysql -uroot -p"${CONFIG_MYSQL_PASSWORD}" --connect-expired-password -e "source ${MYSQL_DATA_PATH}/complete_init.sql"
    log_info "设置成功!"
}

function mysql_init_user()
{
    log_info "正在配置MySQL用户"
    systemctl enable mysqld.service
    systemctl start  mysqld.service
    password=`grep "password" /var/log/mysqld.log |grep 'root@localhost' |awk -F ':' '{print $4}'|sed 's/ //g'`
    log_info "初始化密码是：$password"
    log_info "正在设置EMIC用户和密码[${CONFIG_MYSQL_PASSWORD}]"
    #sed -i "s/emi_ai/${CONFIG_MYSQL_PASSWORD}/" "${MYSQL_RESOURCE_PATH}/init_emic.sql"
    mysql -uroot -p"$password" --connect-expired-password -e "source ${MYSQL_DATA_PATH}/init_emic.sql"
  #  if [[ $? -ne 0 ]]; then
  #      log_error "Init mysql User failed:$?"
  #  fi
  log_info "设置用户名成功!"
}

function mysql_init_tables() {
    log_info "正在导入AI的基础数据库"
    if [[ -d "${MYSQL_DATA_PATH}/" ]];then
        rm  ${MYSQL_DATA_PATH}/mysql -rf
        log_info "删除历史数据"
    fi
    mysql_init_file="${MYSQL_DATA_PATH}/mysql_${CONFIG_VERSION_DATA}.tar.gz"
    log_info $mysql_init_file
    tar -zxvf $mysql_init_file -C ${MYSQL_DATA_PATH}
    if [[ $? -ne 0 ]]; then
        log_error "解压初始化数据失败，请检查[$MYSQL_DATA_PATH]是否存在[mysql_${CONFIG_VERSION_DATA}.tar.gz]"
        exit 1
    fi
    current_dir=`pwd`
    cd  "${MYSQL_DATA_PATH}"
    log_info "正在导入AI的基础数据库[${MYSQL_DATA_PATH} source mysql/add_table.sql]"
    mysql -uroot -p"$CONFIG_MYSQL_PASSWORD" ai --connect-expired-password -e "source mysql/add_table.sql"
    if [[ $? -ne 0 ]]; then
        log_error "Init mysql tables failed:$?"
        log_error "Please check mysql status later！"
    fi
    cd $current_dir
}

#################################
##----------system-------------##
#################################
function  env_system() {
    log_info "正在优化系统配置..."
    log_info "检查系统防火墙..."

}

#################################
##----------docker-------------##
#################################

function env_docker() {
    case "$1" in
    "init")
    log_info "Intall docker[19.03.8] start!"
    DOCKER_RESOURCE_PATH="${BASEHOME}/src/base/docker/"
    DOCKER_TAR_FILE=`find $DOCKER_RESOURCE_PATH -name docker-*.tgz`
    current_dir=`pwd`
    cd $DOCKER_RESOURCE_PATH
    log_info "解压Docker离线包[${DOCKER_TAR_FILE}]"
    tar -zxvf ${DOCKER_TAR_FILE}
    log_info "开始安装docker"
    cp ./docker/* /usr/bin/
    log_info "配置成docker service！"
    if [ ! -d "/etc/docker/" ]; then
        mkdir /etc/docker/
    fi
    cp "${DOCKER_RESOURCE_PATH}/daemon.json" /etc/docker/daemon.json
    cp "${DOCKER_RESOURCE_PATH}/docker.service" /etc/systemd/system/docker.service
    chmod +x /etc/systemd/system/docker.service
    systemctl daemon-reload
    systemctl enable docker.service
    log_info "正在启动docker！"
    systemctl start docker
    log_info "正在验证安装情况！"
    pid=`ps -fe|grep docker |grep -v grep`
    if [[ ! -z $pid ]];then
      log_info "Docker -----Success！"
    else
      log_warn "Test failed,please check"
    fi
    log_info "docker client version： `docker -v`"
           ;;
    "check")
        log_info "正在检查Docker所需要的环境"
        docker_version=`docker -v`
        log_warn "docker未安装,command not found,准备开始安装docker"
        if [[ ! -z $docker_version ]];then
            log_error "已经存在Docker[${docker_version}],请卸载后在尝试!"
            exit 1
        fi
        ;;
    esac
}

#################################
##----------tts-------------##
#################################
function env_tts() {
    log_info "Intall tts[v2.1.3] start!"
    TTS_RESOURCE_PATH="${BASEHOME}/src/tts/v2.0"
    TTS_SERVER_HOME="/var/pbx/tts-server"

    case "$1" in
    "init")
    log_info "正在读取配置:"
    log_info "[监听端口]： ${CONFIG_TTS_PORT}"
    log_info "[授权线路]： ${CONFIG_TTS_NUM}"
    log_info "[安装路径]： ${TTS_SERVER_HOME}"
    current_dir=`pwd`
    cd ${TTS_RESOURCE_PATH}
    if [[ -d $TTS_SERVER_HOME ]]; then
        rm -rf "${TTS_SERVER_HOME}/*"
    else
        mkdir -p ${TTS_SERVER_HOME}
    fi
    log_info "正在拷贝TTS所需要的文件"
    cp ${TTS_RESOURCE_PATH} ${TTS_SERVER_HOME} -R
    #激活license
    #tts_auth_mechine ${CONFIG_TTS_LICENSE}
    log_info "正在配置线路[${CONFIG_TTS_NUM}路]"
    tts_entrance_conf=${TTS_SERVER_HOME}/v2.0/tts-entrance/conf/tts-entrance.conf
    sed -i "s/^SOFA_RPC_CLIENT_NUM .*/SOFA_RPC_CLIENT_NUM : ${CONFIG_TTS_NUM}/g" $tts_entrance_conf
    sed -i "s/^CONCURRENCY_LIMIT .*/CONCURRENCY_LIMIT : $[CONFIG_TTS_NUM*10]/g" $tts_entrance_conf

    if [[ ! "${JAVA_HOME}" ]];then
        log_info "系统没有JDK，正在配置[jdk1.8.0_171]"
        jdk_flag=1
        echo "export JAVA_HOME=${TTS_SERVER_HOME}/v2.0/jdk1.8.0_171" >> /etc/profile
        echo "export JAVA_BIN=$JAVA_HOME/bin" >> /etc/profile
        echo "export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/tools.jar" >> /etc/profile
        echo "export PATH=$PATH:/usr/sbin/:/sbin/:/bin:$JAVA_HOME/bin:$JAVA_HOME/jre/bin" >> /etc/profile
        source /etc/profile
    fi
    log_info "启动http服务"
    tts_lighttpd_dir="${TTS_SERVER_HOME}/v2.0/lighttpd"
    cd $tts_lighttpd_dir
    sed -i "s#^var.rundir .*#var.rundir = \"${tts_lighttpd_dir}\"#g" "${tts_lighttpd_dir}/conf/lighttpd.conf"
    chmod +x *.sh
    chmod +x  ./bin/*

    #配置log FIX:FAQ22
    if [[ ! -d "${TTS_SERVER_HOME}/v2.0/tts-entrance/log" ]];then
        log_info "正在创建tts entrance log 目录[${TTS_SERVER_HOME}/v2.0/tts-entrance/log]"
        mkdir -p "${TTS_SERVER_HOME}/v2.0/tts-entrance/log"
    fi
    if [[ ! -d "${TTS_SERVER_HOME}/v2.0/tts-server/log" ]];then
        log_info "正在创建tts server log 目录[${TTS_SERVER_HOME}/v2.0/tts-server/log]"
        mkdir -p "${TTS_SERVER_HOME}/v2.0/tts-server/log"
    fi

    cd "${TTS_SERVER_HOME}/v2.0/tts-entrance"|| exit
    chmod +x ./bin/*
    chmod +x *.sh

    cd "${TTS_SERVER_HOME}/v2.0/tts-server"
    if [[ ${CONFIG_TTS_TYPE} == 1 ]];then
        mv ./bin/tts-server ./bin/tts-server.2
        mv ./bin/tts-server.1 ./bin/tts-server
    fi
    chmod +x ./bin/*
    chmod +x *.sh

    #配置自启动
    autoStart "tts-server"

    cd $current_dir;
           ;;
    "auth")
        log_info "需要手动授权TTS-----"
    ;;
    "check")
        log_info "正在检查TTS所需要的环境-----[OK]"
        ;;
    "clearup")
        log_info "正在清理TTS安装";
        log_info "正在关闭TTS相关服务";

        if [[ ! $jdk_flag ]]; then
            log_info "使用默认JDK，无需清理"
        else
            log_info "正在清理JDK环境变量";
            unset JAVA_HOME
            unset JAVA_BIN
            unset CLASSPATH
        fi

        log_info "正在删除TTS_SERVER目录[${TTS_SERVER_HOME}]";
        if [[ -d ${TTS_SERVER_HOME} ]]; then
             rm -rf "${TTS_SERVER_HOME}"
        fi
    ;;
    esac
}

#标呗tts自启动
function autoStart()
{
  if [ $1 == "tts-server" ]; then
      log_info "正在配置tts-server自启动"
      chmod +x /etc/rc.d/rc.local
      mv ${diskdir}/tts-server/v2.0/tts_start.sh "${CONFIG_SCRIPT_PATH}/."
      chmod +x ${CONFIG_SCRIPT_PATH}/tts_start.sh
      sed -i '/##tts_auto_start##/,/##tts_auto_start##/d' /etc/rc.d/rc.local
      echo "##tts_auto_start##" >> /etc/rc.d/rc.local
      echo "sh /etc/pbx/scripts/tts_start.sh &>/dev/null" >> /etc/rc.d/rc.local
      echo "##tts_auto_start##" >> /etc/rc.d/rc.local
  fi
}

function env_tools()
{
    case "$1" in
    "init")
        log_warn "暂不支持"
    ;;
    "auth")
        ;;
    esac
}

function factory() {
    case "$1" in
        "mysql")
            env_mysql $2;;
        "redis")
            env_redis $2;;
        "docker")
            env_docker $2;;
        "tools")
            env_tools $2;;
        "system")
            env_system $2;;
        "tts")
            env_tts $2;;
        "all")
            env_mysql $2
            env_docker $2
            env_tools $2
            env_redis $2
            env_tts $2;;
        *)
            echo "No Params！！"
            exit 1
            ;;
    esac
}


factory $@
