#!/bin/bash

set -eo pipefail
shopt -s nullglob

OC_CONF="/home/emi/outcallserver/conf/callingrobot.config"
SUP_CONF="/etc/supervisord.conf"
INSTALL_LOCK="/home/emi/install.lock"
OUTCALL_SERVER_PORT="9009"

if [[ ! -f ${INSTALL_LOCK} ]];then

    cp /var/pbx/oc_conf/callingrobot.config ${OC_CONF}

    if [[ -f "${OC_CONF}" ]];then

        #MYSQL
        if [[ ! -z ${DB_CONN_STR} ]];then
            sed -i 's!<string[ ][ ]*name="db_conn_str">.*<\/string>!<string name="db_conn_str">'${DB_CONN_STR}'<\/string>!g' ${OC_CONF}
        fi
        #Server Port
        if [[ ! -z ${OUTCALL_SERVER_PORT} ]];then
            sed -i 's!<string name="webmanager_listen_port">[0-9]*<.*!<string name="webmanager_listen_port">'${OUTCALL_SERVER_PORT}'</string>!' ${OC_CONF}
        fi
        #Web
        if [[ ! -z ${WEB_API_HOST} ]];then
            sed -i 's!<string[ ][ ]*name="web_api_host">.*<\/string>!<string name="web_api_host">'${WEB_API_HOST}'<\/string>!g' ${OC_CONF}
        fi
        if [[ ! -z ${TTS_SERVER_URL} ]];then
            sed -i 's!<string[ ][ ]*name="db_tts_server_url">.*<\/string>!<string name="db_tts_server_url">'${TTS_SERVER_URL}'<\/string>!g' ${OC_CONF}
        fi
        #TTS
        if [[ ! -z ${TTS_CACHE_SERVER_PORT} ]];then
            sed -i 's!<string[ ][ ]*name="tts_cache_server_port">.*<\/string>!<string name="tts_cache_server_port">'${TTS_CACHE_SERVER_PORT}'<\/string>!g' ${OC_CONF}
        fi
        ##tts_cache_server_ip
        if [[ ! -z ${TTS_CACHE_SERVER_IP} ]];then
            sed -i 's!<string[ ][ ]*name="tts_cache_server_ip">.*<\/string>!<string name="tts_cache_server_ip">'${TTS_CACHE_SERVER_IP}'<\/string>!g' ${OC_CONF}
        fi
         ##tts_cache_server_path
        if [[ ! -z ${TTS_CACHE_LOCAL_PATH} ]];then
            sed -i 's!<string[ ][ ]*name="tts_cached_file_localpath">.*<\/string>!<string name="tts_cached_file_localpath">'${TTS_CACHE_LOCAL_PATH}'<\/string>!g' ${OC_CONF}
        fi
        ##tts_cache_server_start
        if [[ ! -z ${TTS_CACHE_SERVER_START} ]];then
            sed -i 's!<string[ ][ ]*name="tts_cache_server_start">.*<\/string>!<string name="tts_cache_server_start">'${TTS_CACHE_SERVER_START}'<\/string>!g' ${OC_CONF}
        fi

        #FREESWITCH
        # freeswitch_address
        if [[ ! -z ${FREESWITCH_ADDRESS} ]];then
            sed -i 's!<string[ ][ ]*name="freeswitch_address">.*<\/string>!<string name="freeswitch_address">'${FREESWITCH_ADDRESS}'<\/string>!g' ${OC_CONF}
        fi
        if [[ ! -z ${FREESWITCH_INBOUND_PORT} ]];then
            sed -i 's!<int[ ][ ]*name="freeswitch_inbound_port">.*<\/int>!<int name="freeswitch_inbound_port">'${FREESWITCH_INBOUND_PORT}'<\/int>!g' ${OC_CONF}
        fi

        #REDIS
        if [[ ! -z ${REDIS_IP} ]];then
            sed -i 's!<string[ ][ ]*name="redis_ip">.*<\/string>!<string name="redis_ip">'${REDIS_IP}'<\/string>!g' ${OC_CONF}
        fi
        if [[ ! -z ${REDIS_PORT} ]];then
            sed -i 's!<int[ ][ ]*name="redis_port">.*<\/int>!<int name="redis_port">'${REDIS_PORT}'<\/int>!g' ${OC_CONF}
        fi
        if [[ ! -z ${REDIS_PW} ]];then
            sed -i 's!<string[ ][ ]*name="redis_pw">.*<\/string>!<string name="redis_pw">'${REDIS_PW}'<\/string>!g' ${OC_CONF}
        fi
        #ali_tts_server_url
        if [[ ! -z ${TTS_SERVER_URL} ]];then
           sed -i 's!<string name="ali_tts_server_url">[[:print:]]*</string>!<string name="ali_tts_server_url">'${TTS_SERVER_URL}'</string>!'  ${OC_CONF}
        fi
        #ali_tts_appkey
        sed -i 's!<string name="ali_tts_appkey">[[:print:]]*</string>!<string name="ali_tts_appkey">default</string>!'  ${OC_CONF}
        sed -i 's!<string name="ali_tts_key_secret">[[:print:]]*</string>!<string name="ali_tts_key_secret"></string>!'  ${OC_CONF}
        sed -i 's!<string name="ali_tts_access_key_id">[[:print:]]*</string>!<string name="ali_tts_access_key_id"></string>!'  ${OC_CONF}
        sed -i 's!<string name="tts_cache_server_start">0</string>!<string name="tts_cache_server_start">1</string>!'  ${OC_CONF}
        #tts_number
        if [[ ! -z ${TTS_SERVER_URL} ]];then
           robot_num_clue=$[${CONFIG_NUM_TTS} * 2 * 10]
           sed -i 's!<string name="tts_clue_list_size">[[:print:]]*</string>!<string name="tts_clue_list_size">'${robot_num_clue}'</string>!'  ${OC_CONF}
           sed -i 's!<string name="Alitts_limit_QPS">[[:print:]]*</string>!<string name="Alitts_limit_QPS">'${CONFIG_NUM_TTS}'</string>!'  ${OC_CONF}
        fi      
    else  
      echo "No Conf file!!"
    fi
    #定时器任务
    /home/emi/cron/crontab.sh /home/emi/cron/crontab

    touch ${INSTALL_LOCK}
fi

exec "$@"
