#!/bin/bash
SHHOME=$(cd `dirname $0`; pwd)
BASEHOME=$(cd $SHHOME/..; pwd)
CONFIGFILE=$BASEHOME/conf/nls.conf
COMPOSEFILE=$BASEHOME/.nls-compose.yml

cd $BASEHOME
cp -f $CONFIGFILE $BASEHOME/.env

export COMPOSE_HTTP_TIMEOUT=120

chmod +x $SHHOME/docker-compose
#阿里的stop后面加参数就先停止容器 在删除容器
#不加参数默认停止.nls-compose.yml 下面的所有容器
if [ $# -ne 0 ]; then
    $SHHOME/docker-compose -f $COMPOSEFILE stop -t 45 $@
    $SHHOME/docker-compose -f $COMPOSEFILE rm $@
else
    $SHHOME/docker-compose -f $COMPOSEFILE down -t 45
    if [ $? -ne 0 ]; then
        echo "停止失败，请检查磁盘空间 或者 Docker状态"
    fi
fi