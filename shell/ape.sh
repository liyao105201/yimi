#!/bin/bash

# 配置你的应用进程唯一标识
ENDPOINT="https://127.0.0.1"
PROCNAME=apes

SHHOME=$(cd `dirname $0`; pwd)
SCNAME=$(basename $0)
SC=${SHHOME}/${SCNAME}
BASEHOME=$(cd $SHHOME/..; pwd)

CONFIGFILE=$BASEHOME/conf/nls.conf
COMPOSEFILE=$BASEHOME/.apes-compose.yml

cd $BASEHOME
cp -f $CONFIGFILE $BASEHOME/.env
chmod +x $SHHOME/docker-compose
cp -f conf/compose/apes.yml $COMPOSEFILE

diskdir=`cat $CONFIGFILE | grep "^host_disk_dir" | sed "s/host_disk_dir=//g" | tr -d "\r\n"`

User=admin
Passwd=e363865bdcc7b3f7f09c98c6780620ef

function load() {
  if [ $# -gt 0 ] ;then
    for app in $@; do
        for imgName in `find $BASEHOME/images -name "$app*.tar"`
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

function start() {
    docker ps | grep apes > /dev/null
    if [ $? -eq 0 ];then
        echo "Apes started"
        docker ps -a -f name=apes
        exit 0
    fi
    load apes
    $SHHOME/docker-compose -f $COMPOSEFILE up -d
}

function stop() {
    $SHHOME/docker-compose -f $COMPOSEFILE stop apes
}

function restart() {
    stop
    start
}

function usage() {
    echo "start  :start apes" 
    echo "stop   :stop  apes" 
    echo "get    :get machine code" 
    echo "put    :activate license" 
    echo "ctx    :check license" 
    echo "svr    :check services" 
    echo "members   :check apes members" 
    echo "vipserver name  :check vipserver" 
}

function status() {
    ps aux | grep ${PROCNAME} | grep -v "grep"
}

function getlic() {
    curl -k --user ${User}:${Passwd} "$ENDPOINT/vipas/uapi/key/get" -s
    if [ $? -ne 0 ]; then
        echo "[ERROR] curl error. please use curl -k --user ${User}:${Passwd} $ENDPOINT/vipas/uapi/key/get"
    fi
}

function putlic() {
    curl -k --user ${User}:${Passwd} -F key="$1" "$ENDPOINT/vipas/uapi/key/put"
}

function svr() {
    curl -k --user ${User}:${Passwd} "$ENDPOINT/vipas/uapi/svr" -s 
}

function ctx() {
    curl -k --user ${User}:${Passwd} "$ENDPOINT/vipas/uapi/ctx" -s
}
function reset() {
    curl -k --user ${User}:${Passwd} "$ENDPOINT/vipas/uapi/key/del" -s
}

function repair() {
    apesDir="$diskdir/apes/apes.defalut"
    if [ -d "$apesDir" ]; then
        rm -rf $apesDir
        echo "clean data...finish repair..."
    else
        echo "cannot found data..."
    fi
}

function members() {
    curl -k --user ${User}:${Passwd} "$ENDPOINT/vipas/members" -s
}

function vipserver() {
    if [[ "$2" == "all" ]]; then
        curl -k --user ${User}:${Passwd} "$ENDPOINT/vipserver/api/allDomNames"
    else
        curl -k --user ${User}:${Passwd} "$ENDPOINT/vipserver/api/srvIPXT?dom=$2" 
    fi
}

case "$1" in
    "get")
      	getlic ;;
    "put")
      	putlic $2 ;;
    "svr")
        svr ;;
    "ctx")
        ctx ;;
    "reset")
        reset ;;
    "start")
        start ;;
    "stop")
        stop ;;
    "restart")
        restart ;;
    "repair")
        repair ;;
    "status")
        status ;;
    "members")
        members ;;
    "vipserver")
        vipserver $@ ;;
    *)
        usage ;;