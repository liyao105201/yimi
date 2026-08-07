#!/bin/bash
#此脚本针对公司现网环境mrcp安装
path=/var/pbx
mrcp_path=/var/pbx/mrcp
conf_path=$mrcp_path/data/nls-cloud-sdm/conf
conf_nlstoken=nlstoken.json
conf_service_asr=service-asr.json
conf_service_tts=service-tts.json
conf_nls_AccessKeyId="LTAI1uGQxImzHj5b"
conf_nls_AccessKeySecret="PenF9dDYppdGHt0Vsj5wGJu6xhv3HY"
conf_asr_appkey="iEBY8AfhOsZ8Gfaw"
log_path=/var/pbx/logs/nls-cloud-sdm
function log_info(){
    echo -e "\033[32m [INFO] $@ \033[0m"
}

function log_warn() {
    echo -e "\033[33m [WARN] $@ \033[0m"
}

function pull() {
    docker pull registry.cn-shanghai.aliyuncs.com/nls-cloud/sdm
}

function fix_conf() {
    sleep 30
    cd ${conf_path}
    log_info "当前文件路径:"
    pwd 
    log_info "正在修改配置文件$conf_nlstoken"
    echo "sed -i 's/\"AccessKeyId\":[[:print:]]*/\"AccessKeyId\":\"${conf_nls_AccessKeyId}\",/' ${conf_nlstoken}"
    echo "sed -i 's/\"AccessKeySecret\":[[:print:]]*/\"AccessKeySecret\":\"${conf_nls_AccessKeySecret}\",/' ${conf_nlstoken}"
    log_info "正在修改配置文件$conf_service_asr"
    echo "sed -i 's/\"appkey\":.*/\"appkey\":\"${conf_asr_appkey}\",/' ${conf_service_asr}"
    sed -i 's/"AccessKeyId":[[:print:]]*/"AccessKeyId":"'${conf_nls_AccessKeyId}'",/' ${conf_nlstoken}
    sed -i 's/"AccessKeySecret":[[:print:]]*/"AccessKeySecret":"'${conf_nls_AccessKeySecret}'",/' ${conf_nlstoken}
    sed -i 's/"appkey":.*/"appkey":"'${conf_asr_appkey}'",/' ${conf_service_asr}
}

function install_mrcp() {
    log_info "准备安装mrcp镜像文件"
    pull
    if [[ -d $mrcp_path ]];then
        log_info "mrcp文件夹路径$mrcp_path"
    else
        log_info "正在建立文件夹 $mrcp_path"
        mkdir $mrcp_path -p
    fi
    log_info "正在启动mrcp"
    docker images|grep sdm
    if [[ $? -eq 0 ]];then
        cd $mrcp_path
        log_info "docker run -d --privileged --net=host --name nls-cloud-sdm   -v `pwd`/logs:/home/admin/logs -v `pwd`/data:/home/admin/disk registry.cn-shanghai.aliyuncs.com/nls-cloud/sdm:latest standalone"
        docker run -d --privileged --net=host --name nls-cloud-sdm   -v `pwd`/logs:/home/admin/logs -v `pwd`/data:/home/admin/disk registry.cn-shanghai.aliyuncs.com/nls-cloud/sdm:latest standalone
    else
        exit 1
    fi 
    log_info "正在启动容器,请稍等"
    sleep 30
}

function main() {
    install_mrcp
    fix_conf
    docker restart nls-cloud-sdm
    log_info "配置生效重新启动中"
	sleep 10
    ps -ef | grep alimrcp-server|grep './al'
    sleep 10
    if [[ $? -eq 0 ]];then
       log_warn "mrcp启动成功"
    fi
}
main