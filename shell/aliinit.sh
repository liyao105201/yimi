#!/bin/bash
SHHOME=$(cd `dirname $0`; pwd)
BASEHOME=$(cd $SHHOME/..; pwd)

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
}

function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
}

function log_warn() {
    echo -e "\033[33m [WARN] $@ \033[0m"
    echo "WARN $@"  >> $StartLogFile
}

docker images > /dev/null 2>&1
if [ $? -ne 0 ];then
    log_error "执行Docker命令失败"
    log_error "[可能原因1] Docker未启动， systemctl start docker.service"
    log_error "[可能原因2] 权限不够，使用sudo 或者 将该用户加入docker用户组 sudo gpasswd -a \${USER} docker"
    exit 1
fi

function load() {
  if [ $# -gt 0 ] ;then
    for app in $@; do
        for imgName in `find $BASEHOME/images -name "$app.tar"`
        do 
            echo "load $imgName"
            docker load --input $imgName
        done
        #docker load --input $BASEHOME/images/$app.tar
    done
  else
    for imgName in `find $BASEHOME/images -name "*.tar"`
    do 
        echo "load $imgName"
        docker load --input $imgName
    done
  fi
}

function doLoad() {
    case "$1" in
        "apes")            load apes;;
        "tts")
            load nls-cloud-gateway nls-cloud-tts;;
        "asr")
            load nls-cloud-redis nls-cloud-gateway nls-cloud-jupiter-blend nls-cloud-jupiter-flow nls-cloud-realtime nls-cloud-unify-post nls-cloud-unify-post-eas nls-cloud-fusion nls-cloud-vad;;
        "trans")
            load nls-cloud-redis nls-cloud-gateway nls-cloud-jupiter-blend nls-cloud-filetrans nls-cloud-unify-post nls-cloud-unify-post-eas nls-cloud-vad;;
        "slp")
            load nls-cloud-mysql nls-cloud-redis nls-cloud-mongodb nls-cloud-slp nls-cloud-ai-container nls-cloud-ntwer;;
        "sfr")
            load nls-cloud-mysql nls-cloud-gacs nls-cloud-sidl;;
        "lid")
            load nls-cloud-lid;;
        "sdm")
            load nls-cloud-sdm nls-cloud-sdmproxy;;
        "mgr")
            load nls-cloud-mysql nls-cloud-animus nls-cloud-admin nls-cloud-meta;;
        "dev")
            load nls-cloud-mysql nls-cloud-router nls-cloud-device-manager;;
        "monitor")
            load nls-cloud-node-exporter nls-cloud-cadvisor nls-cloud-cockpit;;
        "aca")
            load nls-cloud-redis nls-cloud-gateway nls-cloud-jupiter-blend nls-cloud-realtime nls-cloud-unify-post nls-cloud-unify-post-eas nls-cloud-vad nls-cloud-modelexpo nlp-ca-es nlp-ca-alarm-call-analysis;;
        "all")
            load ;;
        *)
            load $*;;
    esac
}
#校验和解压ASR和自学习平台相关资源
function checkResource() {
    if [ ! -d "$BASEHOME/resource/$1" ];then
        echo "not exist resource for $1, 尝试从resource目录下解压资源包"
        if [ -f "$BASEHOME/resource/$1.tar.gz" ]; then
            cd $BASEHOME/resource/
            tar -xf $1.tar.gz
        else
            log_error "$BASEHOME/resource/$1 目录和$BASEHOME/resource/$1.tar.gz 不存在，无法启动 [nls-cloud-$1]，如不需启动该应用则忽略"
        fi
    else
        log_info "check success: $BASEHOME/resource/$1 目录存在"
    fi
}

log_info  "校验和解压ASR和自学习平台相关资源(首次部署时解压缩较慢，请耐心等候，注意不要强制终止...): "echo $BASEHOME

checkResource "jupiter-blend"
checkResource "unify-post"
checkResource "ai-container"
checkResource "slp"

if [ $# -gt 0 ]; then
    doLoad $@
else 
cat << EOF

+-------------------------------------------------+
                  容器初始化   
请按需加载服务，例如：
    * [install all service input all]加载所有服务则输入 all  
    * 加载语音识别相关服务，则输入 asr
    * 加载单独服务 则输入对应镜像名 比如 nls-cloud-gateway

      ---全量服务---
      [all]    全部

      ---基础服务---
      [apes]   语音授权&中心管理服务
      [mgr]    语音管理类服务
      [dev]    语音设备管理类服务

      ---语音识别---
      [asr]    语音识别全链路服务，包括一句话识别，实时语音识别
      [trans]  录音文件识别全链路服务
      [slp]    语音识别定制化服务(自学习平台)
      [lid]    实时语种识别服务

      ---语音合成---
      [tts]    语音合成全链路服务

      ---语音对话管理---
      [sdm]    语音对话管理(MRCP)服务
      
      ---语音监控管理系统---
      [monitor]   语音监控、报警管理系统

+-------------------------------------------------+
EOF
    echo -n "请输入:"
    read module
    doLoad $module
fi

        