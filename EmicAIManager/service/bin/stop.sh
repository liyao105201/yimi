#!/bin/bash
#关闭服务
# @author Hukaijun@emicnet.com
# ./stop.sh tts-server
# ./stop.sh mysql
script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
cd $EMICHOME

#tts操作
function tts_server_control()
{
     case "$1" in
        "stop")

         *)
          echo "No Params！！"
          exit 1
          ;;
     esac
}

#关闭服务
function server_control() {
    case "$1" in
        "tts-server")
            tts_server_control $2;;
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

function main() {
    echo "正在关闭服务！"
    #安装环境
    for compant in $@;do
    echo "init env for emic_ai with $compant"
        if [[ ! -z $compant ]]; then
            server_control $compant "stop"
        fi
    done
}
main $@