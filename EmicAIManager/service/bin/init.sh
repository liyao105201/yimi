#!/bin/bash
##demo
# @author HuKaijun<Hukaijun@emicnet.com>

## 安装独立组件
## ./init.sh mysql
## 多个组件可以一起来
## ./init.sh mysql redis docker tts
## 不带参数表示安装全部
## ./init.sh
script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
cd $EMICHOME

function show_tips() {
cat << EOF
+-------------------------------------------------+
                  易米AI智能语音自动化安装器
      ---版权所有---
      [version]              2.0.1
      [author]               Hukaijun<hukaijun@emicent.com>
      [company]              南京易米云通网络科技有限公司版权所有
      ---使用方式---
      [init]                 ./init.sh cpm 初始化系统
      [start]                ./start.sh 启动服务
      [stop]                 ./stop.sh  关闭服务
      [update]               ./update.sh [组件名] 升级系统
      [mysql]                ./mysql update|init|  sql_file  升级初始化
      ---日志位置---
      manager.log
+-------------------------------------------------+
EOF
}
show_tips

#host模式
function host_init()
{
  host_file="/etc/hosts"
    cat << EOF
+-------------------------------------------------+
|                2.正在设置网络                    |
+-------------------------------------------------+
EOF
cp $host_file "/etc/host_bak"
#删除古老的配置
sed -i '/##emic_ai_host_setting##/,/##emic_ai_host_setting##/d' $host_file
log_info "Setting server domain"
echo "##emic_ai_host_setting##" >> $host_file
echo "${CONFIG_REDIS_HOST}  ${EMIC_REDIS_HOST}" >> $host_file
echo "|    ${CONFIG_REDIS_HOST}  ${EMIC_REDIS_HOST}"
echo "${CONFIG_MYSQL_HOST}  ${EMIC_MYSQL_HOST}" >> $host_file
echo "|    ${CONFIG_MYSQL_HOST}  ${EMIC_MYSQL_HOST}"
echo "${CONFIG_FREESWITCH_HOST}  ${EMIC_FREESWITCH_HOST}" >> $host_file
echo "|    ${CONFIG_FREESWITCH_HOST}  ${EMIC_FREESWITCH_HOST}"
echo "${CONFIG_OUTCALL_HOST}  ${EMIC_OUTCALL_HOST}" >> $host_file
echo "|    ${CONFIG_OUTCALL_HOST}  ${EMIC_OUTCALL_HOST}"
echo "${CONFIG_AICALL_HOST}  ${EMIC_AICALL_HOST}" >> $host_file
echo "|    ${CONFIG_AICALL_HOST}  ${EMIC_AICALL_HOST}"
echo "${CONFIG_TTS_HOST}  ${EMIC_TTS_HOST}" >> $host_file
echo "|    ${CONFIG_TTS_HOST}  ${EMIC_TTS_HOST}"
echo "${CONFIG_ASR_HOST}  ${EMIC_ASR_HOST}" >> $host_file
echo "|    ${CONFIG_ASR_HOST}  ${EMIC_ASR_HOST}"
echo  "##emic_ai_host_setting##" >> $host_file
cat << EOF
+-------------------------------------------------+
EOF
log_info "正在测试网络连接"
network_ping ${EMIC_REDIS_HOST}
network_ping ${EMIC_MYSQL_HOST}
network_ping ${EMIC_FREESWITCH_HOST}
network_ping ${EMIC_OUTCALL_HOST}
network_ping ${EMIC_AICALL_HOST}
network_ping ${EMIC_TTS_HOST}
network_ping ${EMIC_ASR_HOST}
}

function network_ping() {
  domain_name=$1
  ping ${domain_name} -c 2
  if [[ $? -eq 0 ]];then
  log_info "connet $domain_name success"
  else
  log_error "connet $domain_name failed"
  fi
}

#安装基础环境
function env_init() {

    for compant in $@;do
        echo "init env for emic_ai with $compant"
        if [[ ! -z $compant ]]; then
            /bin/bash ./env.sh $compant init
            if [[ $? -ne 0 ]]; then
                log_info "init $compant failed，please check log"
                log_error $?
            fi
        fi
    done
}

function load() {

  if [ $# -gt 0 ] ;then
    for app in $@; do
        for imgName in `find $BASEHOME/images -name "$app*.tar"`
        do
            log_info "load $imgName"
            docker load --input $imgName
        done
    done
  else
    for imgName in `find $BASEHOME/images -name "*.tar"`
    do
        log_info "load $imgName"
        docker load --input $imgName
    done
  fi
}



function doLoad() {
   cat << EOF
+-------------------------------------------------+
                  容器初始化

      ---Freeswitch服务---
      [aicall]              web提供界面
      [outcall_server]      外呼服务 任务管理
      [freeswitch]          Freeswitch服务
      [mysql]               数据库服务
      [redis]               缓存服务
+-------------------------------------------------+
EOF
   echo "Start load images"
   load freeswitch aicall outcall_server
   echo "Load images success!"
}

function keepClear()
{
   log_info "正在设置定时器清理任务[${EMICHOME}/cron/crontab]"
   if [[ -f ${BASEHOME}/cron/crontab ]];then
      if [[ ! -d ${CONFIG_CRONTAB_PATH} ]];then
          log_info "正在初始化CRON目录[${CONFIG_CRONTAB_PATH}]"
          mkdir -p  ${CONFIG_CRONTAB_PATH}
      fi
      if [[ ! -d ${CONFIG_SCRIPT_PATH} ]];then
          log_info "正在初始化script目录[${CONFIG_SCRIPT_PATH}]"
          mkdir -p  ${CONFIG_SCRIPT_PATH}
      fi
      cp ${BASEHOME}/cron/crontab ${CONFIG_CRONTAB_PATH}/crontab
      cp "${BASEHOME}/cron/clear.sh" ${CONFIG_SCRIPT_PATH}/clear.sh
      crontab ${CONFIG_CRONTAB_PATH}/crontab
      if [[ $? -ne 0 ]];then
        log_warn "设置失败：$?"
      else
         log_info "设置成功!"
      fi
   else
     log_warn "没有crontab文件，无法设置清理定时器"
   fi
}



function check {

cat << EOF
+-------------------------------------------------+
|                检查系统相关信息                    |
+-------------------------------------------------+
EOF
    log_info "[系统内核版本]"
    log_info `uname -a`
    if [ -f /etc/redhat-release ]; then
        log_info `cat /etc/redhat-release`
    fi
    log_info "[Docker版本]"
    log_info `docker -v`

    DockerRootDir=`docker info  | grep "Docker Root Dir" | awk '{print $4}'`
    if [ $? -eq 0 ]; then
        log_info "[Docker根目录]"
        log_info $DockerRootDir
        df -hl $DockerRootDir
        PUsedDisk=`df -hl $DockerRootDir | awk 'NR==2{print $5}' | sed 's/%//g'`
        if [ $PUsedDisk -gt 90 ]; then
            log_warn "Insufficient disk space 可用磁盘空间过低"
            log_warn "[$DockerRootDir]磁盘可用空间过低, 已使用[$PUsedDisk]%"
        fi
    fi

    log_info "[Workspace工作目录]"
    log_info $BASEHOME
    log_info `df -hl $BASEHOME`
    PUsedDisk=`df -hl $BASEHOME | awk 'NR==2{print $5}' | sed 's/%//g'`
    if [ $PUsedDisk -gt 90 ]; then
        log_warn "Insufficient disk space 可用磁盘空间过低"
        log_warn "[$BASEHOME] 磁盘可用空间过低, 已使用[$PUsedDisk]%"
    fi

    log_info "[CPU信息]"
    log_info `cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c`
    CPUHZ=`cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c | awk '{print $8}' | awk -F 'G' '{print $1}'`
    if [ $(echo "$CPUHZ < 2.5"|bc) = 1 ]; then
        log_warn "CPU主频${CPUHZ}GHZ 低于2.50GHz, 性能将无法达到指标或应用可能无法成功启动"
    fi
    grep "avx2" /proc/cpuinfo > /dev/null
    if [ $? -ne 0 ]; then
        log_warn "CPU不支持AVX2指令集，性能将无法达到指标或应用可能无法成功启动"
    fi

    log_info "[内存信息]"
    log_info `free -g`
    FreeMem=`free -g | grep "Mem"  | awk '{print $7}'`
    if [ $FreeMem -lt 10 ]; then
        log_warn "Insufficient mem size 可用内存过低"
        log_warn "系统可用内存过低, 剩余[$FreeMem]GB"
    fi

    log_info "[系统资源信息]"

    ulimit -a
    log_info `ulimit -a`

    sfd=`ulimit -Sn`
    if [ $sfd -lt 655350 ]; then
        log_warn "系统文件描述符配置较低(ulimit -Sn) $sfd < 655350, 请参考文档进行系统级优化"
    fi

    hfd=`ulimit -Hn`
    if [ $hfd -lt 655350 ]; then
        log_warn "系统文件描述符配置较低(ulimit -Hn) $hfd < 655350, 请参考文档进行系统级优化"
    fi

    log_info "[日志目录]: $NLSLOGDIR"

    log_info "[运行数据目录]: "$NLSDATADIR""
}

function main() {

    #硬件检查
    log_info "初始化配置文件/etc/hosts"
    host_init
    #env_check
    echo "正在检查系统配置！"
    #安装环境
    for compant in $@;do
    echo "init env for emic_ai with $compant"
        if [[ ! -z $compant ]]; then
            /bin/bash ./env.sh $compant "check"
            if [[ $? -ne 0 ]]; then
                log_error "Check env $compant failed:$?"
            else
                echo "check env for emic_ai with $compant is[OK]"
                /bin/bash ./env.sh $compant init
                if [[ $? -ne 0 ]]; then
                    log_info "init $compant failed，please check log"
                    log_error $?
                fi
            fi
        fi
    done
    #载入容器
    #doLoad
    #加入定时器清理
    keepClear

    echo "程序执行完成，请手动检查各个组件是否正常，然后进行下一步操作"
}

main $@