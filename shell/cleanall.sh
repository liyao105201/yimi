#!/bin/bash
function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
}

cat <<EOF
+-------------------------------------------------+
|           此脚本针对容器镜像，请谨慎使用           |
+-------------------------------------------------+
EOF
delcontainers(){  
    cat <<EOF
+-------------------------------------------------+
|                  删除容器                        |
+-------------------------------------------------+
EOF
    containers=`docker ps -a -q`
    docker kill $containers
    docker rm $containers
}
delimages(){
        cat <<EOF
+-------------------------------------------------+
|                 删除镜像                         |
+-------------------------------------------------+
EOF
    delcontainers
    images=`docker images -a -q`
    docker rmi $images -f
}
cat << EOF
+-------------------------------------------------+
                  卸载清理工具   
请按需选择卸载方式，例如：
      ---全量服务---
      [containers]   只删除运行的容器服务，不会删除已经导入的镜像和volume
      ---全量服务---
      [images]       删除当前主机上所有容器和已经导入的镜像及volume
+-------------------------------------------------+
EOF
read -p "请选择删除镜像 or 容器：删除容器输入：containers，删除镜像输入images" choose
case $choose in：
  "containers")
  delcontainers
  ;;
  "images")
  delimages
  ;;
  *)
  log_error "你输入的参数不在选择中，请重新选择，删除镜像 or 容器：删除容器输入：containers，删除镜像输入images"
  ;;
esac