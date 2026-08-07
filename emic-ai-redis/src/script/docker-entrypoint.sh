#!/bin/bash

set -eo pipefail
shopt -s nullglob
#修改配置

INSTALL_LOCK="/etc/pbx/redis/install_v1.lock"
REDIS_ORGIN_CONF="/etc/pbx/redis/redis.conf.orgin"
REDIS_CONF="/etc/redis/redis.conf"
REDIS_CONF_BAK="/etc/redis/redis.conf.bak"


if [[ ! -f ${INSTALL_LOCK} ]];then
  if [[ ! -f ${REDIS_CONF} ]];then
    cp -f $REDIS_CONF  $REDIS_CONF_BAK
    echo "正在备份文件:$REDIS_CONF_BAK"
  fi
  cp -f ${REDIS_ORGIN_CONF} $REDIS_CONF
  echo "config redis port and requirepass"

  if [[ ! -z ${REDIS_PORT} ]];then
    echo "REDIS_PORT=${REDIS_PORT}"
    sed -i "s/port[ ][ ]*6379/port ${REDIS_PORT}/g"  ${REDIS_CONF}
  fi

  if [[ ! -z ${REDIS_REQUIREPASS} ]];then
    echo "REDIS_REQUIREPASS=${REDIS_REQUIREPASS}"
    sed -i "s!requirepass[ ][ ]*greeisgood!requirepass ${REDIS_REQUIREPASS}!g"  ${REDIS_CONF}
  fi

  touch ${INSTALL_LOCK}
fi

echo "start emic redis success!"
exec "$@"
