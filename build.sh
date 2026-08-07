#!/bin/bash

#version:V3.0
#set -x
# V3 打包器
# **注意**
# 系统中默认账号涉及公司机密，代码中予以删除，实际使用时请咨询相关人员
#
#
# 执行命令如下
# build.sh [name] [version] [is_push]
# name:组件名称，如oc fs web 或者 outcallserver freeswitch aicall
# version:版本如v42.1.89789
# is_push:是否推送到远端
# 例子：
# ./build.sh -m emic-ai-trimule -t V22.11.14 -p 1
# 会生成 freeswitch:V3.5.1 的镜像
# sed -i 's/\r$//' build.sh
# 解决windows上存在回车符的问题
#const
ALIYUN_NAME_SPACE="tutorial"
IMAGE_NAME="aicall"
RELEASE_USER="root"
ALIYUN_USERNAME='lichuanhu@emicloud'
ALIYUN_PASSWORD='Sinicnet123456'
ERROR_DEFAULT=1

#param.
DOCKERFILE='Dockerfile'
#test DockerFile
DOCKERFILE_CENTOS="Dockerfile"

#var
ERROR_DEFAULT=1
LOG_INFO=""
SVN_AUTHOR="hukaijun"
SVN_PASSWORD="hukaijun"
SVN_URL="http://192.168.1.66/svn/namtso/branch/web_code/emic_phone/web_aicall"

#@MARK：需要描述一下参数列表
show_usage(){
    cat <<EOF
    Exec command like: ./build.sh -m -H 83033 -t V42.6.83033
    Usage: 参数类型本程序不做校验，全靠自觉
      -h                    Helper for shell.
      -m                    soft model
      -v|V                  version
      -f                    pack file
      -t <project-version>  Tag name:look like: r2.5_r3
      -H <svn-Header>       svn version egg:62345
EOF
}

show_version()
{
    echo "version: v3.0"
    echo "company: emic.com.cn"
    echo "updated date: 2022年07月25日"
}

#参数分析
#
analysis_params(){
    #soft path
    SOFT_PATH=$(cd `dirname $0`; pwd)
    DIST_PATH="${SOFT_PATH}/dist"
    if [[ ! -d ${DIST_PATH} ]];then
      mkdir -p ${DIST_PATH}
    fi
    # 入口参数分析
    TEMP=`getopt -o hvVm:t:H:p:f: --long help,version,model:,tag:,svn:,push:,file: -- "$@" 2>/dev/null`

    if [[ ! $? -eq  0 ]]; then
        echo -e "\033[31mERROR: unknown argument! \033[0m\n"
        show_usage
        exit 1
    fi
    # 会将符合getopt参数规则的参数摆在前面，其他摆在后面，并在最后面添加--
    eval set -- "${TEMP}"
    while :
    do

        [ -z "$1" ] && break;
        case "$1" in
            -H|--svn)
                SVN_REVERSION=$2; shift 2
            ;;
            -t|--name)
                TAG_NAME=$2; shift 2
            ;;
            -m|--model)
                SOFT_MODEL=$2; shift 2
            ;;
            -p|--push)
                IS_PUSH=$2; shift 2
            ;;
            -f|--file)
                PACK_FILE=$2; shift 2
            ;;
            --)
                shift
                ;;
            -h|--help)
                show_usage; exit 0
            ;;
            -v|-V|--version)
                show_version; exit  0
            ;;
            *)
             echo -e "\033[31mERROR: unknown argument! \033[0m\n" && show_usage && exit 1
             ;;
           esac
    done

    echo  $PACK_FILE
    echo  $IS_PUSH
    echo  $SOFT_MODEL
    echo  $TAG_NAME
    echo  $SVN_REVERSION

    #V3版本重新命名
    if [[ ${SOFT_MODEL} == "oc"  ||  ${SOFT_MODEL} == "outcall_server" || ${SOFT_MODEL} == "outcallserver" ]] ; then
      SOFT_NAME="outcall_server"
      IMAGE_NAME='emic-ai-oc'
    elif [[ ${SOFT_MODEL} == "web"  ||  ${SOFT_MODEL} == "aicall" ]]; then
      SOFT_NAME="aicall"
      IMAGE_NAME="emic-ai-web"
    elif [[ ${SOFT_MODEL} == "fs"  ||  ${SOFT_MODEL} == "freeswitch" ]]; then
      SOFT_NAME="freeswitch"
      IMAGE_NAME="emic-ai-freeswitch"
    elif [[ ${SOFT_MODEL} == "redis"  ]]; then
      SOFT_NAME="redis"
      IMAGE_NAME="emic-ai-redis"
    elif [[ ${SOFT_MODEL} == "mysql"  ]]; then
      SOFT_NAME="mysql"
      IMAGE_NAME="emic-ai-mysql"
    elif [[ ${SOFT_MODEL} == "trimule" ||  ${SOFT_MODEL} == "emic-ai-trimule"  ]]; then
      SOFT_NAME="trimule"
      IMAGE_NAME="emic-ai-trimule"
    elif [[ ${SOFT_MODEL} == "no_match"  ]]; then
      SOFT_NAME="no_match_server"
      IMAGE_NAME="emic-ai-nms"
    else
      echo "You input soft model is [${SOFT_MODEL}],but not allowed,please check it!"
      exit $ERROR_DEFAULT;
    fi

#    if [[ -n "${SVN_REVERSION}"  &&  ${SOFT_NAME} == "aicall" ]]; then
#        echo "You must be use the option '--svn' or '-H' to describe SVN number!"
#        show_usage
#        exit $ERROR_DEFAULT;
#    fi
    if [[ -z ${TAG_NAME} ]];then
        echo " You must be use the option '-t' "
        show_usage
        exit 0
    fi
    if [[ -z ${SOFT_MODEL} ]];then
        echo " You must be use the option '-m' to describe project name!"
        show_usage
        exit 0
    fi
}
#清理服务器上的老数据
clear_exists_image(){
    echo "Cleaning the old images and containers about【${TAG_NAME}】"
    docker_stop_count=`docker ps -a | grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $1 }'|wc -l`
    if [[ $docker_stop_count -eq 0 ]];then
      echo "No containers about 【${TAG_NAME}】need stop"
    else
        docker ps -a | grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $1 }'|xargs docker stop
    fi
    docker_delete_container=`docker ps -a | grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $1 }'|wc -l`
    if [[ $docker_delete_container -eq 0 ]];then
      echo "No containers about 【${TAG_NAME}】need delete"
    else
        docker ps -a | grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $1 }'|xargs docker rm
    fi
    docker_delete_images=`docker images| grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $2 }'|wc -l`
    if [[ $docker_delete_images -eq 0 ]];then
      echo "No images about 【${TAG_NAME}】need delete"
    else
        docker images| grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $2 }'|xargs docker rmi
    fi
    # docker system prune -a -f
    echo "Clean finish!"
}

# 定制化业务打包逻辑
#
create_oc_version()
{
    echo "正在生成镜像，请稍后"
    docker build -t ${IMAGE_NAME}:${TAG_NAME} -f ${DOCKERFILE_CENTOS} ./
    docker_image=`docker images|grep ${TAG_NAME}|awk '{print $2 }'`
    echo "镜像创建成功【${docker_image}】"
}

# 定制化业务打包逻辑
#
create_docker_image(){
#      SOFT_NAME=$1
      current_path=`pwd`
      if [[ ! -d ${SOFT_PATH}/${IMAGE_NAME} ]];then
         echo  "No soft name is [${IMAGE_NAME}]"
         exit ${ERROR_DEFAULT};
      fi
      cd ${SOFT_PATH}/${IMAGE_NAME}
      echo  "Packing the soft ${SOFT_NAME} to docker image!"
      case $IMAGE_NAME in
      "aicall"|"emic-ai-web")
        create_web_version

        rm -rf ./website
        ;;
      "freeswitch"|"emic-ai-freeswitch")
        create_fs_version
        ;;
      "outcall_server"|"outcallserver"|"emic-ai-oc")
        create_oc_version
      ;;
      "emic-ai-trimule")
      create_trimule_version
      ;;
      *)
        echo "No such image!!!"
        ;;
      esac
      cd $current_path


#创建trimule
create_trimule_version(){
    echo "Packing the soft 【emic-ai-trimule】 to docker image!"
    DEFAULT_PACK_FILE=${SOFT_PATH}/emic-ai-trimule/src/pack/Trimule.tar.gz
    if [[ ! -f $PACK_FILE  ]];then
          echo  $(pwd)
          write_log "Sorry,pack file [$PACK_FILE] is not existed! Use default file path [$DEFAULT_PACK_FILE]"
    else
          #删除包
          rm -f ${DEFAULT_PACK_FILE}
          #拷贝指定文件
          cp $PACK_FILE ${SOFT_PATH}/emic-ai-trimule/src/pack/
    fi
    #切换到编译目录
    current_path=$(pwd)
    cd ${SOFT_PATH}/emic-ai-trimule
    docker build -t ${IMAGE_NAME}:${TAG_NAME} .
    docker_image=$(docker images|grep ${IMAGE_NAME}|grep ${TAG_NAME})
    if [[ $? == 0 ]];then
      echo "Images build success【${docker_image}】"
    fi
    cd ${current_path}
}

#创建emic-ai-web
create_web_version(){
    echo  "Packing the soft 【emic-ai-web】 to docker image!"
    echo "Sync data by svn for aicall !"

    if [[ -z ${PACK_FILE} ]];then
      if [[ -z $SVN_REVERSION ]];then
           #没指定版本认为是最新版
           SVN_REVERSION=`svn info ${SVN_URL}|grep '最后修改的版本:'|cut -d' ' -f2`
      fi
      svn checkout ${SVN_URL} website -r ${SVN_REVERSION}  --username ${SVN_AUTHOR} --password ${SVN_PASSWORD}
      if [[ $? != 0 ]];then
          echo "SVN 同步数据失败！"
          exit $ERROR_DEFAULT
      fi
      echo "正在创建版本名称【${TAG_NAME}】对应的SVN版本【${SVN_REVERSION}】"
    fi
    #文件传输模式
    if [[ -d ${PACK_FILE} ]];then
      echo "当前使用文件模式打包[${PACK_FILE}]，请确认当前版本的正确性！"
        rm -rf ./website
        tar -zxvf ${PACK_FILE} -C ./
        if [[ $? != 0 ]];then
          echo  "文件 ${PACK_FILE} 类型错误，必须为tar.gz"
          exit $ERROR_DEFAULT
        fi
    fi
    #写入版本号
    version_file="./website/aicall_version.txt"
    if [[ -f ${version_file} && ! -z ${SVN_REVERSION} ]];then
        echo  "product version: ${SVN_REVERSION}" >> ${version_file}
    fi
    #创建数据data包
    dist_path="${DIST_PATH}/data";
    if [[ ! -d $dist_path ]]; then
        mkdir $dist_path -p;
    fi
    data_file="${dist_path}/mysql_${SVN_REVERSION}.tar.gz";
    if [[ -f $data_file ]]; then
        rm $data_file -rf;
        echo "正在删除已经存在的数据版本${data_file}"
    fi
    cd ./website/shell/
#    tar -czvf ../..${data_file} ./mysql/
#    if [[ $? != 0 ]]; then
#         echo "get data failed!"
#    fi
#    echo "get data Success！!"
    #添加redis配置
    cd ../
    redis_file=./extend/core/common/config.php
    sed -i 's/47.94.139.172/redis.emic/' ${redis_file}
    echo "Change redis config success!"
    cd ../
    build_docker_image
}


#执行打包脚本
build_docker_image()
{
    echo "Building images, please wait"
    docker build -t ${IMAGE_NAME}:${TAG_NAME} -f ${DOCKERFILE_CENTOS} ./
    docker_image=$(docker images|grep ${TAG_NAME}|awk '{print $2 }')
    echo "Images build success【${docker_image}】"
}

create_fs_version(){
    current_path={pwd}
    cd ${SOFT_PATH}/emic-ai-freeswitch
    docker build -t ${SOFT_NAME}:${TAG_NAME} ./
    docker_image=$(docker images|grep ${TAG_NAME}|grep ${SOFT_NAME} |awk '{print $2 }')
}

write_log() {
	LOG_INFO=$1
	echo "${LOG_INFO}"
}

user_check() {
	if [[ $(whoami) != ${RELEASE_USER} ]];then
		write_log "sorry, you are not ${RELEASE_USER}."
		exit ${ERROR_DEFAULT}
	fi
	if [[ ! -f ${DOCKERFILE} ]];then
		  write_log "sorry, you DIR has no Dockerfile"
      exit ${ERROR_DEFAULT}
	fi
}

# shellcheck disable=SC2120
build_docker_image()
{
    echo "Building images, please wait"
    docker build -t ${IMAGE_NAME}:${TAG_NAME} -f ${DOCKERFILE_CENTOS} ./
    command="docker images|grep ${TAG_NAME}|awk '{print $2 }'"
    eval ${command}
    if [[ $? -ne 0 ]];then
        write_log "Login docker hub is failed!"
        exit ${ERROR_DEFAULT}
    fi
    echo "Images build success【${docker_image}】"
}

pack_docker_image()
{
    echo "paking images, please wait"
    dist_path="../dist/images";
    if [[ ! -d $dist_path ]]; then
        mkdir $dist_path -p;
    fi
    data_file="${dist_path}/${IMAGE_NAME}.${TAG_NAME}.tar";
    if [[ -f $data_file ]]; then
        rm $data_file -r;
        echo "正在删除已经存在的镜像版本${data_file}"
    fi
    docker save -o $data_file ${IMAGE_NAME}:${TAG_NAME}
    if [[ $? != 0 ]]; then
         echo "get images failed!"
    fi
    echo "get images Success！!"
}

aliyun_docker_login()
{
    username="$1"
    password="$2"

  #  echo ${password} | docker login --username=${username} --password-stdin registry.cn-hangzhou.aliyuncs.com | grep 'Login Succeeded'
    command="docker login --username=${username} --password=${password} registry.cn-hangzhou.aliyuncs.com | grep 'Login Succeeded'"
    result=exec $command
    if [[ result -ne 0 ]];then
        write_log "Login docker hub is failed!"
        exit ${ERROR_DEFAULT}
    fi
}

push_image_aliyun()
{
    echo "Pushing to Alibaba cloud, please wait!"
    aliyun_docker_login ${ALIYUN_USERNAME} ${ALIYUN_PASSWORD}
    docker tag ${IMAGE_NAME}:${TAG_NAME} registry.cn-hangzhou.aliyuncs.com/tutorial/${IMAGE_NAME}:${TAG_NAME}
    docker push registry.cn-hangzhou.aliyuncs.com/tutorial/${IMAGE_NAME}:${TAG_NAME}
    echo "image build and push ${TAG_NAME} success!";
    docker tag ${IMAGE_NAME}:${TAG_NAME} registry.cn-hangzhou.aliyuncs.com/tutorial/${IMAGE_NAME}
    docker push registry.cn-hangzhou.aliyuncs.com/tutorial/${IMAGE_NAME}
    echo "image build and push laster success!";
}

exec(){
  command=$1
  write_log  "Process running ${command}"
  eval ${command}
  if [[ $? -ne 0 ]];then
      write_log "Exec the command failed!"
  fi
  return $?
}


main(){
    analysis_params $@
    #docker check images list
    clear_exists_image
    #svn update code for app
    create_docker_image
    #push to aliyun docker server
    if [[ ${IS_PUSH} == 1 ]]; then
        push_image_aliyun
    fi
    pack_docker_image

}

#执行函数
main $@