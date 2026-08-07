#!/bin/bash

#const
ALIYUN_NAME_SPACE="tutorial"
IMAGE_NAME="aicall"
RELEASE_USER="root"
ALIYUN_USERNAME='lichuanhu@emicloud'
ALIYUN_PASSWORD='Sinicnet123456'
ERROR_DEFAULT=1

#param
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
    Exec command like: ./build.sh -H 91137 -t V43.6.91137
    Usage: 参数类型本程序不做校验，全靠自觉
      -h                    Helper for shell.
      -v|V                  version
      -t <project-version>  Tag name:look like: r2.5_r3
      -H <svn-Header>       svn version egg:62345
EOF
}

show_version()
{
    echo "version: v3.0"
    echo "company: emicnet.com"
    echo "updated date: 2022年07月25日"
}

# 入口参数分析
TEMP=`getopt -o hvVt:H: --long help,version,tag:,header: -- "$@" 2>/dev/null`

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
        -H|--header)
            SVN_REVERSION=$2; shift 2
        ;;
        -t|--name)
            TAG_NAME=$2; shift 2
        ;;
        --)
            shift
            ;;
        -h|--help)
            show_usage; exit 0
        ;;
        -v|-V|--version)
            show_version; exit 0
        ;;
        *)
         echo -e "\033[31mERROR: unknown argument! \033[0m\n" && show_usage && exit 1
         ;;
       esac
done

#function

create_docker_version(){
    echo "正在同步svn"
    if [[ -z SVN_REVERSION ]];then
         #没指定版本认为是最新版
         SVN_REVERSION=`svn info ${SVN_URL}|grep 'Last Changed Rev'|cut -d' ' -f4`
    fi
    #删除原来的
    rm ./website/ -rf
    #更新最新的
    svn checkout ${SVN_URL} website -r r${SVN_REVERSION}  --username ${SVN_AUTHOR} --password ${SVN_PASSWORD}

    if [[ $? != 0 ]];then
        echo "Checkout svn code failed!"
        exit 1
    fi
    #删除.svn文件
    echo "正在删除svn版本控制文件"
    rm ./website/.svn -rf
    echo "正在创建版本名称【${TAG_NAME}】对应的SVN版本【${SVN_REVERSION}】"
    #写入版本号
    version_file="./website/aicall_version.txt"
    if [[ -f ${version_file} ]];then
        echo  "product version: ${SVN_REVERSION}" >> ${version_file}
    fi
    #创建数据data包
    dist_path="../dist/data";
    if [[ ! -d $dist_path ]]; then
        mkdir $dist_path -p;
    fi
    data_file="${dist_path}/mysql_${SVN_REVERSION}.tar.gz";
    if [[ -f $data_file ]]; then
        rm $data_file -rf;
        echo "正在删除已经存在的数据版本${data_file}"
    fi
    current_path=`pwd`
    cd ./website/shell/
    tar -czvf ../../${data_file} ./mysql/
    if [[ $? != 0 ]]; then
         echo "get data failed!"
    fi
    echo "get data Success！!"
    #添加redis配置
    cd ../
    redis_file=./extend/core/common/config.php
    sed -i 's/47.94.139.172/redis.emic/' ${redis_file}
    echo "redis 替换成功"
    cd $current_path
}

clear_exists_image(){
    echo "正在检查是否已经存在该版本并清理【${TAG_NAME}】"
    docker ps -a | grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $1 }'|xargs docker stop
    docker ps -a | grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $1 }'|xargs docker rm
    #docker images| grep ${TAG_NAME} | grep ${IMAGE_NAME} | awk '{print $2 }'|xargs docker rmi
}

write_log() {
	LOG_INFO=$1
	echo "${LOG_INFO}"
}

init() {
	if [[ `whoami` != ${RELEASE_USER} ]];then
		write_log "sorry, you are not ${RELEASE_USER}."
		exit ${ERROR_DEFAULT}
	fi
	if [[ ! -f ${DOCKERFILE} ]];then
		write_log "sorry, you DIR has no Dockerfile4"
        exit ${ERROR_DEFAULT}
	fi
}

build_docker_image()
{
    echo "Building images, please wait"
    docker build -t ${IMAGE_NAME}:${TAG_NAME} -f ${DOCKERFILE_CENTOS} ./
    docker_image=`docker images|grep ${TAG_NAME}|awk '{print $2 }'`
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
        rm $data_file -rf;
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
    result=`docker login --username=${username} --password=${password} registry.cn-hangzhou.aliyuncs.com | grep 'Login Succeeded'`
    if [[ ${result} ]];then
        echo "aliyun Login Succeeded"
    fi
}

push_image_aliyun()
{
    echo "Pushing to Alibaba cloud, please wait!"
    aliyun_docker_login ${ALIYUN_USERNAME} ${ALIYUN_PASSWORD}
    docker tag ${IMAGE_NAME}:${TAG_NAME} registry.cn-hangzhou.aliyuncs.com/tutorial/${IMAGE_NAME}:${TAG_NAME}
    docker push registry.cn-hangzhou.aliyuncs.com/tutorial/${IMAGE_NAME}:${TAG_NAME}
    echo "image build and push success!";
}

main(){
    init
    #svn update code for app
    create_docker_version
    #docker check images list
    clear_exists_image
    #build docker images
    build_docker_image
    #push to aliyun docker server
#    push_image_aliyun
    pack_docker_image
}

#执行函数
# ./build.sh -H 65520 -n r3.1_r1
main $@
