#!/bin/bash

set -eo pipefail
shopt -s nullglob

DB_CONF="/var/pbx/website/config/database.php"
NGINX_HOST_CONF="/etc/nginx/conf.d/default.conf"
INSTALL_LOCK="/var/pbx/website/install.lock"
web_config="/var/pbx/website/config"
or_config='/var/pbx/website/config_orgin/'
server_init_path="/var/pbx/website/shell/server-init.sh"

if [[ ! -f ${INSTALL_LOCK} ]];then

    echo "Installing aiweb!"
    #设置配置
    if [[ -d ${web_config} ]];then
        local_linux_time=$(date "+%Y%m%d%H%M%S")
        bak_config="${web_config}_${local_linux_time}"
        mkdir -p ${bak_config}
        cp ${web_config} ${bak_config} -R  #remove last branch config
        echo "create bak file ${bak_config}"
    fi
    if [[ -d ${or_config} ]];then
        rm /var/pbx/website/config/* -rf
        mv -f /var/pbx/website/config_orgin/* /var/pbx/website/config
        rm -rf /var/pbx/website/config_orgin/
    fi

    if [[ ! -z ${MYSQL_HOST} ]];then
        echo "MYSQL_HOST=${MYSQL_HOST}"
        sed -i 's/rm-2ze4h4gd92r731iapeo.mysql.rds.aliyuncs.com/'${MYSQL_HOST}'/' ${DB_CONF}
    fi
    if [[ ! -z ${MYSQL_USER} ]];then
        echo "MYSQL_USER=${MYSQL_USER}"
        sed -i 's/emi_ai/'${MYSQL_USER}'/' ${DB_CONF}
    fi
    #host model need http port
    if [[ ! -z ${HTTP_PORT} ]];then
        echo "HTTP_PORT=${HTTP_PORT}"
        sed -i 's/10251/'${HTTP_PORT}'/g' ${NGINX_HOST_CONF}
    fi
    if [[ ! -z ${HTTPS_PORT} ]];then
        echo "HTTPS_PORT=${HTTPS_PORT}"
        sed -i 's/10252/'${HTTPS_PORT}'/g' ${NGINX_HOST_CONF}
    fi
    if [[ ! -z ${MYSQL_PASSWORD} ]];then
        echo "MYSQL_PASSWORD=${MYSQL_PASSWORD}"
        sed -i 's/Sinicnet123456/'${MYSQL_PASSWORD}'/' ${DB_CONF}
    fi
    #callback
    if [[ -f ${server_init_path} ]];then
      if [[ ! -z ${JOIN_SERVICE} ]];then
            echo "Need join service ${JOIN_SERVICE}"
            nohup sh ${server_init_path} ${JOIN_SERVICE} &
      fi
    fi
    #定时器
    cd /var/pbx/website/shell/
    /var/pbx/website/shell/run.sh crontab
    #数据库
#    sql=""
#    if [[ ! -z ${OC_SERVER} ]];then
#        sql="UPDATE \`aicall_config\` SET \`value\` = '${OC_SERVER}' WHERE \`key\` = 'outcall_server_host';"
#    fi
#    if [[ ! -z ${OC_PROXY} ]];then
#        sql=${sql}" UPDATE \`aicall_config\` SET \`value\` = '${OC_PROXY}' WHERE \`key\` = 'outcall_server_host';"
#    fi
    #mysql -h ${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "${sql}" >/dev/null#mysql -h ${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "${sql}" >/dev/null
    touch ${INSTALL_LOCK}
fi
echo "start ai_web success!"
exec "$@"
