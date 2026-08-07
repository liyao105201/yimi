#!/bin/bash
SHHOME=$(cd `dirname $0`; pwd)
BASEHOME=$(cd $SHHOME/..; pwd)

SHOST="127.0.0.1"
cd $BASEHOME

CONFIGFILE=$BASEHOME/conf/nls.conf
logsdir=`cat $CONFIGFILE | grep "^host_logs_dir" | sed "s/host_logs_dir=//g" | tr -d "\r\n"`
NLSLOGDIR=$(cd $logsdir; pwd)

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
}

function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
}

docker images > /dev/null 2>&1
if [ $? -ne 0 ];then
    log_error "执行Docker命令失败"
    log_error "[可能原因1] Docker未启动， systemctl start docker.service"
    log_error "[可能原因2] 权限不够，使用sudo 或者 将该用户加入docker用户组 sudo gpasswd -a \${USER} docker"
    exit 1
fi

docker ps
#监测服务器是否启动程序。-检查端口是否存在
checkPort() {
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/$1/$2"
    return $?
}

checkService() {
    serviceName=$1
    tcpPort=$2
    
    serviceLogDir=$NLSLOGDIR/$serviceName

    aliasName=`echo $serviceName | sed 's/nls-cloud/nls/g'`
    if [ ! -z "$aliasName" ]; then
        if [ -d "$NLSLOGDIR/$aliasName" ]; then 
            serviceLogDir=$NLSLOGDIR/$aliasName
        fi
    fi
    checkPort $SHOST $tcpPort
    if [ $? -eq 0 ]; then
        log_info "[$serviceName] TcpPort:[$tcpPort] ok. LogPath:$serviceLogDir"
    else 
        log_error "[$serviceName] TcpPort:[$tcpPort] failed, please check log! LogPath:$serviceLogDir "
    fi
}

while read line
do
    serviceName=`echo $line | awk -F"|" '{print $1}'`
    servicePort=`echo $line | awk -F"|" '{print $2}'`
    docker ps | grep "$serviceName" > /dev/null
    if [ $? -eq 0 ]; then
        checkService $serviceName $servicePort
    else
        log_info "[$serviceName] 容器未发现, 默许为用户选装, 自动忽略"
    fi
done < $BASEHOME/conf/service.list