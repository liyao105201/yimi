#!/bin/bash
# 数据库管理工具
# 数据库升级
# mysql.sh update [版本号：缺省最新]
# 数据库备份
# mysql.sh bak [目录]
# 数据库回退
# mysql.sh rollback [目录:由mysql bak生成]

script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
cd $EMICHOME

#检查是否有客户端
function check_mysql_client(){
  res=`mysql --version`
  if [ $res -eq 0 ]; then
      log_error "You need Install MySQL_client"
      exit 1
  fi
    log_info "Check mysql env[$res] success!"
}

function check_sqlfile(){
    log_info "正在检查数据库升级文件"
    UPDATE_SQL_FILE=$1
    if [[ ! -f $UPDATE_SQL_FILE ]]; then
      log_error "No update sql file, Please connet EMIC!"
      exit 1
    fi
}

function mysql_update(){
    log_info "正在准备升级数据库"
    check_sqlfile $2
    LAST_SQL_VERSION=`get_last_sql_version`
    log_info "当前数据库版本是[$LAST_SQL_VERSION]"
}

function mysql_backup() {
    comfirom "在您备份前请确定关闭应用服务" 'xtest 1'
}

function xtest(){
  echo $1
}

function comfirom(){
  read -n1 -p "${1} [Y/N]?" answer
  case $answer in
  Y | y) echo
    `eval $2`
    echo "Running....";;
  N | n) echo
    echo "You hava canceled .."
    exit;;
  esac
}



#main
function main()
{
  check_mysql_client

  case "$1" in
    "update")
        mysql_update $2
    ;;
    "bak")
        mysql_backup $2
        ;;
    "rollback")
        mysql_rollback $2
        ;;
     *)
      log_error "Null parameter!"
      exit 1
      ;;
    esac
}


main $@