#!/bin/bash
#命令调用方式
#./build.sh 42.6.87432

#const
ALIYUN_NAME_SPACE="tutorial"
IMAGE_NAME="outcall_server"
RELEASE_USER="root"
#RELEASE_USER="root"
ALIYUN_USERNAME='lichuanhu@emicloud'
ALIYUN_PASSWORD='Sinicnet123456'

ERROR_DEFAULT=1

#param
INPUT_VERSION=${1}
HEAD_VERSION=''
DOCKERFILE='Dockerfile'
DOCKERFILE_CENTOS="Dockerfile"

#var
DOCKER_VERSION_PREFIX="v${INPUT_VERSION}"
LOG_INFO=""
#SVN_AUTHOR="hukaijun"
#SVN_PASSWORD="hukaijun"
#SVN_URL="http://192.168.1.66/svn/namtso/branch/web_code/emic_phone/web_aicall"
DOCKER_VERSION=""
JUST_PUSH=$3

#function

create_docker_version(){
    echo "正在创建版本"
    DOCKER_VERSION="${DOCKER_VERSION_PREFIX}"
#    svn co ${SVN_URL}  --username ${SVN_AUTHOR} --password ${SVN_PASSWORD}
#    mv web_aicall website
    echo "正在创建版本名称【${DOCKER_VERSION}】"
}

clear_exists_image(){
    echo "正在检查是否已经存在该版本并清理【${DOCKER_VERSION}】"
    docker ps -a | grep ${DOCKER_VERSION} | awk '{print $1 }'|xargs docker stop
    docker ps -a | grep ${DOCKER_VERSION} | awk '{print $1 }'|xargs docker rm
    #MARK：为了缓存可以不删除
    #docker images|grep ${DOCKER_VERSION}|awk '{print $2 }'|xargs docker rmi
}

write_log() {
	LOG_INFO=$1
	echo "${LOG_INFO}"
}

init() {
    if [[ ! ${INPUT_VERSION} ]];then
        write_log "sorry, you are not version param."
        exit ${ERROR_DEFAULT}
    fi
#    if [[ -z ${HEAD_VERSION} ]];then
#        write_log "sorry, you are not head version param."
#        exit ${ERROR_DEFAULT}
#    fi
	if [[ `whoami` != ${RELEASE_USER} ]];then
		write_log "sorry, you are not ${RELEASE_USER}."
		exit ${ERROR_DEFAULT}
	fi
	if [[ ! -f ${DOCKERFILE} ]];then
		write_log "sorry, you DIR has no Dockerfile[${DOCKERFILE}]"
        exit ${ERROR_DEFAULT}
	fi
}

build_docker_image()
{
    echo "正在生成镜像，请稍后"
    docker build -t ${IMAGE_NAME}:${DOCKER_VERSION} -f ${DOCKERFILE_CENTOS} ./
    docker_image=`docker images|grep ${DOCKER_VERSION}|awk '{print $2 }'`
    echo "镜像创建成功【${docker_image}】"
}

aliyun_docker_login()
{
    username="$1"
    password="$2"

  #  echo ${password} | docker login --username=${username} --password-stdin registry.cn-hangzhou.aliyuncs.com | grep 'Login Succeeded'
    result=`docker login --username=${username} --password=${password} registry.cn-hangzhou.aliyuncs.com | grep 'Login Succeeded'`
    if [[ ${result} ]];then
        echo "aliyun Login Succeeded"
    fi
}

push_image_aliyun()
{
    echo "正在推送镜像，请稍后"
    aliyun_docker_login ${ALIYUN_USERNAME} ${ALIYUN_PASSWORD}
    tag_name=${IMAGE_NAME}:${DOCKER_VERSION}
    docker tag ${tag_name} registry.cn-hangzhou.aliyuncs.com/tutorial/${IMAGE_NAME}:${DOCKER_VERSION}
    docker push registry.cn-hangzhou.aliyuncs.com/tutorial/${IMAGE_NAME}:${DOCKER_VERSION}
    echo "image build and push success!";
}

##### 入口函数
main()
{
    #params check
    #逻辑代码
    #init
    init

    #svn update code for app
    create_docker_version

    #docker check images list
    clear_exists_image

    #build docker images
    build_docker_image

    #push to aliyun docker server
    if [[ ! -z ${JUST_PUSH} ]];then
        echo "正在推送到远程镜像库>>>"
        push_image_aliyun
    fi

}

main






