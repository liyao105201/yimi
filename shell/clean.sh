#!/bin/bash

function log_warn() {
    echo -e "\033[33m [WARN] $@ \033[0m"
}


function delContainer() {
    docker kill $(docker ps -a | grep -E "nls-cloud*|modelexpo|apes" | awk '{print $1}')
    docker rm -f $(docker ps -a | grep -E "nls-cloud*|modelexpo|apes" | awk '{print $1}')
    docker rm $(docker ps --all -q -f status=dead)
}

function delImages() {
    delContainer

    docker rmi -f $(docker images | grep -E "nls-cloud*|modelexpo|apes" | awk '{print $1}')
    docker volume rm $(docker volume ls -qf dangling=true)
}

cat << EOF
+-------------------------------------------------+
                  卸载清理工具   
请按需选择卸载方式，例如：
      ---全量服务---
      [service]   只删除运行的容器服务，不会删除已经导入的镜像和volume
      ---全量服务---
      [all]       删除当前主机上所有容器和已经导入的镜像及volume
+-------------------------------------------------+
EOF

echo -n "请输入[service/all]:"
read key
case "$key" in
    "service")
        delContainer ;;
    *)
        delImages ;;
esac