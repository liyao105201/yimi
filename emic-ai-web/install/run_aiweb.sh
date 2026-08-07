#!/bin/bash

#set -x
#@MARK:项目名称 对应阿里云
IMAGE_NAME=""  #aicall
PROJECT_VERSION="1.0"

#system const
ALIYUN_NAME_SPACE="tutorial"
REGISTER_URL="registry.cn-hangzhou.aliyuncs.com"
ALIYUN_USERNAME='lichuanhu@emicloud'
ALIYUN_PASSWORD='Sinicnet123456'

#params
TAG_NAME=""
IMAGE_ID=""

#@MARK：需要描述一下参数列表
show_usage(){
    cat <<EOF
    Usage:
      -u <mysql_user>   mysql的username
      -p <mysql_password>   mysql的密码
      -H <mysql_host>       mysql的host
      -O <oc server>        oc服务器地址
      -P <oc proxy>         oc定向路由
      -r <http_port>        http端口号
      -x <https_port>       https端口号
      -m <mount url>        mount地址
      -f <file>             配置文件.ini格式
      -n <project-version>  指定的版本号： r2.5_r2
      -v                    version
      -h                    Helper for shell.
EOF
}

show_version()
{
    echo "version: aicall_docker_run ${PROJECT_VERSION}"
    echo "updated date: 2019-09-01"
}

write_log() {
	LOG_INFO=$1
	echo "${LOG_INFO}"
}

exec_command()
{
    result=`$1`
    message=$2
    if [[ $? != 0 ]]; then
        echo -e "\033[31mERROR: ${1} exec failed: ${message} \033[0m\n"
        exit 1
    fi
}

# 入口参数分析
TEMP=`getopt -o hvVn:u:p:H:O:P:r:x:m:f: --long help,version,name:,mysql_user:,mysql_password:,mysql_host:,oc_server:,oc_proxy:,http_port:,https_port:,mount_url:,file: -- "$@" 2>/dev/null`

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
        -h|--help)
            show_usage; exit 0
        ;;
        -v|-V|--version)
            show_version; exit 0
        ;;
        -f|--file)
            CONFIG_FILE=$2; shift 2
        ;;
        -u|--mysql_user)
            MYSQL_USER=$2; shift 2
        ;;
        -p|--mysql_password)
            MYSQL_PASSWORD=$2; shift 2
        ;;
        -H|--mysql_host)
            MYSQL_HOST=$2; shift 2
        ;;
        -n|--name)
            IMAGE_NAME=$2; shift 2
        ;;
        -r|--http_port)
            PROJECT_HTTP_PORT=$2; shift 2
        ;;
        -x|--https_port)
            PROJECT_HTTPS_PORT=$2; shift 2
        ;;
        -O|--oc_server)
            OC_SERVER=$2; shift 2
        ;;
        -P|--oc_proxy)
            OC_PROXY=$2; shift 2
        ;;
        -m|--mount_url)
            MOUNT_URL=$2; shift 2
        ;;
        --)
            shift
            ;;
        *)
         echo -e "\033[31mERROR: unknown argument! \033[0m\n" && show_usage && exit 1
         ;;
       esac
done

#project config
PROJECT_LOG="/var/pbx/tmp/logs"
PROJECT_MOUNT="/var/pbx/upload/"
PROJECT_WEBSITE_CONFIG="/etc/aicall/web/config"
#测试环境
PROJECT_PATH="/var/pbx"

get_config()
{
    iniFile=$1
    section=$2
    option=$3
    iniValue=`awk -F '=' '/['${section}']/{a=1}a==1&&$1~/'${option}'/{print $2;exit}' ${iniFile}`
    iniValue=`echo ${iniValue} |sed 's/\"//g'`
    echo ${iniValue}
}
exit_run(){
    echo -e "Fatal error:\033[31mERROR: ${1} \033[0m\n"
    exit 1
}

parse_file()
{
    IMAGE_NAME=`get_config $1 "AI_WEB" "IMAGE_NAME"`
    TAG_NAME=`get_config $1 "AI_WEB" "TAG_NAME"`
    PROJECT_HTTP_PORT=`get_config $1 "AI_WEB" "PROJECT_HTTP_PORT"`
    PROJECT_HTTPS_PORT=`get_config $1 "AI_WEB" "PROJECT_HTTPS_POR"`
    MYSQL_USER=`get_config $1 "AI_WEB" "MYSQL_USER"`
    MYSQL_HOST=`get_config $1 "AI_WEB" "MYSQL_HOST"`
    MYSQL_PASSWORD=`get_config $1 "AI_WEB" "MYSQL_PASSWORD"`
    OC_PROXY=`get_config $1 "AI_WEB" "OC_PROXY"`
    OC_SERVER=`get_config $1 "AI_WEB" "OC_SERVER"`
    MOUNT_URL=`get_config $1 "AI_WEB" "MOUNT_URL"`
    IS_OFFLINE=`get_config $1 "common" "IS_OFFLINE"`
}

#functions
aliyun_docker_login()
{
    username="$1"
    password="$2"
  #  echo ${password} | docker login --username=${username} --password-stdin registry.cn-hangzhou.aliyuncs.com | grep 'Login Succeeded'
    result=`docker login --username=${username} --password=${password} registry.cn-hangzhou.aliyuncs.com | grep 'Login Succeeded'`
    if [[ ! ${result} ]];then
        echo "aliyun Login failed!"
        exit 1
    fi
    echo "login success!"
}

docker_install()
{
	echo "检查服务器Docker环境!"
	docker -v
    if [[ ! $? -eq  0 ]]; then
        echo "检查到尚未安装docker环境..."
        cat /etc/os-release | grep ID= |awk -F'"' '{print $2}'|xargs|grep "centos"
        if [[ $? -eq 0 ]];then
            exit_run "系统尚未安装Docker环境,请先安装";
            #exec_command "yum -y install docker-ce"
        else
            write_log "您的操作系统[$?]不能自动安装,请自行安装再执行！"
            exit 1
        fi
        echo "安装docker环境...安装完成!"
    fi
    echo "检查到Docker已安装!"
}

pull_image_offline(){
    offline_file=$1
    if [[ ! -f ${offline_file} ]];then
        exit_run "没有离线镜像文件[${offline_file}]"
    fi

    docker load < ${offline_file}
    if [[ $? -ne 0 ]];then
        exit_run "镜像加载失败:[$?]"
    fi
}

#初始化
init(){

    if [[ -f ${CONFIG_FILE} ]];then
        parse_file ${CONFIG_FILE}
    fi
    #check params
    if [[ ! ${IMAGE_NAME} ]];then
        write_log "You need input image name with [-n\--name] in command！"
        exit 1
    fi
    #docker env
    docker_install

    if [[ ${IS_OFFLINE} -eq 1 ]];then
        offline_file="${IMAGE_NAME}.${TAG_NAME}.tar.gz"
        pull_image_offline ${offline_file}
    else
        #aliyun login
        aliyun_docker_login ${ALIYUN_USERNAME} ${ALIYUN_PASSWORD}
        #pull images
        docker pull ${REGISTER_URL}/${ALIYUN_NAME_SPACE}/${IMAGE_NAME}:${TAG_NAME}
    fi
}

#检查docker 运行环境
image_check(){
    echo "正在检查当前服务器版本"
    if [[ ${IS_OFFLINE} -eq 1 ]];then
        current_image=`docker images | grep ${IMAGE_NAME} | awk '{print $3 }'`
    else
        current_image=`docker images | grep ${REGISTER_URL}/${ALIYUN_NAME_SPACE}/${IMAGE_NAME} | awk '{print $3 }'`
    fi

    echo "pull版本:${current_image}"
    if [ "$current_image" == "" ];then
        write_log "No image with this server，you can use 【docker images】show them!"
        exit 1
    fi
    #关闭已经运行的同类型的image
    echo "正在关闭【${IMAGE_NAME}】容器！"

    docker ps -a | grep ${IMAGE_NAME} | awk '{print $1 }'|xargs docker stop
    #删除本地none镜像
    echo "正在删除本地none镜像！"
    docker images|grep none|awk '{print $3 }'|xargs docker rmi -f
}

#
mysql_connect_check(){

    mysql -h${1} -u${2} -p${3} -e quit 2>&1
    if [[ $? -eq 0 ]]; then
        exit_run "mysql connect error!:$?"
    fi
    echo "mysql test success!"
}

#
mount_data(){
    df |grep "/var/pbx/upload/robot"
    if [[ ! $? -eq 0 ]];then
        mkdir -p /var/pbx/upload/robot
        if [[ -z $1 ]];then
            exit_run "无法创建目录"
        fi
        if [[ -z ${MOUNT_URL} ]];then
            echo "未接受到MOUNT_URL,需要手动mount数据卷"
            return 1
        else
            echo "正在挂载目录"
            mount -t nfs -o rw ${1} ${2}
            if [[ ! $? -eq 0 ]];then
                exit_run "挂载失败请检查目录或网络挂载主体是否已经配置正确"
            fi
        fi
    fi
}

run_ready(){
    echo "正在准备运行docker"
    if [[ ! -d ${PROJECT_LOG} ]]; then
        mkdir -p ${PROJECT_LOG}
        echo "创建日志目录：${PROJECT_LOG}"
    fi
    if [[ ! -d ${PROJECT_MOUNT} ]]; then
        mkdir -p ${PROJECT_MOUNT}
    fi
    #检查挂载
    echo "检查数据挂载目录：${PROJECT_MOUNT}"
    mount_data ${MOUNT_URL} ${PROJECT_MOUNT}

    mysql_connect_check ${MYSQL_HOST} ${MYSQL_USER} ${MYSQL_PASSWORD}
}

#安装新的docker images
run_container()
{
    run_ready
    echo "正在启动容器..."
     if [[ ! -d ${PROJECT_LOG}/${IMAGE_NAME}_${TAG_NAME}/ ]];then
        mkdir -p ${PROJECT_LOG}/${IMAGE_NAME}_${TAG_NAME}
    fi

	local_linux_time=$(date "+%Y%m%d%H%M%S")
	container_name=${IMAGE_NAME}_${local_linux_time}
    command="docker run -it -d --restart=always  --name ${container_name} -p ${PROJECT_HTTP_PORT}:10251 -p ${PROJECT_HTTPS_PORT}:443"
    command="${command} -v ${PROJECT_MOUNT}:/var/pbx/upload -v ${PROJECT_LOG}/${IMAGE_NAME}_${TAG_NAME}:/var/pbx/tmp/logs"
    command="${command} -v ${PROJECT_WEBSITE_CONFIG}:/var/pbx/website/config"

    command="${command} --env MYSQL_HOST=${MYSQL_HOST} --env MYSQL_USER=${MYSQL_USER} --env MYSQL_PASSWORD=${MYSQL_PASSWORD}"

    if [[ -z ${OC_SERVER} ]];then
        command="${command} --env  OC_SERVER=${OC_SERVER}"
    fi
    if [[ -z ${OC_PROXY} ]];then
        command="${command} --env  OC_PROXY=${OC_PROXY}"
    fi

    full_image_name=${REGISTER_URL}/${ALIYUN_NAME_SPACE}/${IMAGE_NAME}:${TAG_NAME}
    if [[ ${IS_OFFLINE} -eq 1 ]];then
        full_image_name=${IMAGE_NAME}:${TAG_NAME}
    fi
    command="${command} $full_image_name"
    echo  "正在执行 ${command}"

    #old_container=`docker ps | awk '{print $1 }' | wc -l`
    eval ${command}
    #new_container=`docker ps | awk '{print $1 }' | wc -l`
    #if [ "$new_container" -gt "$old_container" ];then
    new_container=`docker ps | grep "$name" | wc -l`
    if [[ "$new_container" -gt "0" ]];then
	    echo "容器启动成功"
	    return 1
    fi
	
	exit_run "容器启动失败"
}

#运行主程序

main(){
    init
    image_check
    run_container
}

#执行
main
