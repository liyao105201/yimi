#!/bin/bash
SHHOME=$(cd `dirname $0`; pwd)
BASEHOME=$(cd $SHHOME/..; pwd)
CONFIGFILE=$BASEHOME/conf/nls.conf
COMPOSEFILE=$BASEHOME/.nls-compose.yml
COMPOSE_VERSION="2.1"

MSGFILE=$BASEHOME/.msg

logsdir=`cat $CONFIGFILE | grep "^host_logs_dir" | sed "s/host_logs_dir=//g" | tr -d "\r\n"`
diskdir=`cat $CONFIGFILE | grep "^host_disk_dir" | sed "s/host_disk_dir=//g" | tr -d "\r\n"`
resdir=`cat $CONFIGFILE | grep "^host_res_dir" | sed "s/host_res_dir=//g" | tr -d "\r\n"`
run_uid=`cat $CONFIGFILE | grep "^run_uid" | sed "s/run_uid=//g" | tr -d "\r\n"`
containerdir=/home/admin

cd $BASEHOME

mkdir -p ${diskdir}
mkdir -p ${logsdir}
NLSLOGDIR=$(cd $logsdir; pwd)
NLSDATADIR=$(cd $diskdir; pwd)

StartLogFile=${NLSLOGDIR}/start.log
ErrorLogFile=${NLSLOGDIR}/start_error.log
WarnLogFile=${NLSLOGDIR}/start_warn.log

function sysOptimzation {
    if [ X$USER == X"root" ];then
        sudo sysctl -w net.ipv4.ip_local_port_range="10000 64000"
    fi
}
#权限准备
function parpareVolumeDirs {
    mkdir -p ${diskdir}
    mkdir -p ${logsdir}
    if [ X$USER == X"root" ];then
        test -d ${logsdir} && chmod a+w $logsdir
        test -d ${diskdir} && chmod a+w $diskdir
        which setenforce > /dev/null && setenforce 0
    fi
}

function prepareAiContainer {
    if [ -d $resdir/ai-container/algos ]; then
        if [ ! -d $diskdir/nls-cloud-ai-container/algos ]; then
            mkdir -p $diskdir/nls-cloud-ai-container
    fi
        rm -f $diskdir/nls-cloud-ai-container/algos
        ln -s $containerdir/resource/ai-container/algos $diskdir/nls-cloud-ai-container/algos
        log_info "加载资源包数据成功$diskdir/nls-cloud-ai-container/algos"
    fi
    if [ -d $resdir/ai-container/v3 ]; then
        if [ ! -d $diskdir/nls-cloud-ai-container/v3 ]; then
            mkdir -p $diskdir/nls-cloud-ai-container/v3
        fi

        rm -f $diskdir/nls-cloud-ai-container/v3/algos
        ln -s $containerdir/resource/ai-container/v3/algos $diskdir/nls-cloud-ai-container/v3/algos
        log_info "加载资源包数据成功$diskdir/nls-cloud-ai-container/v3"
    fi
}

function prepareSLP {
    docker images | grep nls-cloud-ai-container > /dev/null
    if [ $? -ne 0 ];then
        log_info "未加载nls-cloud-ai-container,忽略训练数据"
        return
    fi

    log_info "自学习预先初始化训练依赖数据"
    
    mkdir -p $diskdir/nls-cloud-slp/asr/lm
    mkdir -p $diskdir/nls-cloud-slp/asr/am

    if [ ! -f $diskdir/nls-cloud-slp/asr/lm/common-eng-tn.txt ]; then
        cp -f $resdir/slp/common-eng-tn.txt $diskdir/nls-cloud-slp/asr/lm/common-eng-tn.txt
    fi

    if [ ! -f $diskdir/nls-cloud-slp/asr/lm/common-seg-dict.txt ]; then
        cp -f $resdir/jupiter-blend/resources/asr/models/default/latest/lm/segment.dict $diskdir/nls-cloud-slp/asr/lm/common-seg-dict.txt
    fi    if [ ! -f $diskdir/nls-cloud-slp/asr/am/am-train-resource.zip ]; then
        cp -f $resdir/jupiter-blend/resources/asr/models/default/latest/am-train-resource.zip $diskdir/nls-cloud-slp/asr/am/am-train-resource.zip
    fi

    if [ ! -f $diskdir/nls-cloud-slp/asr/api_ngram.cfg ]; then
        cp -f $resdir/jupiter-blend/resources/asr/models/default/latest/api_ngram.cfg $diskdir/nls-cloud-slp/asr/api_ngram.cfg
    fi

    if [ ! -f $diskdir/nls-cloud-slp/asr/am/am.net ]; then
        cp -f $resdir/jupiter-blend/resources/asr/models/default/latest/am/am.net $diskdir/nls-cloud-slp/asr/am/am.net
    fi

    if [ ! -f $diskdir/nls-cloud-slp/asr/am/am.mvn ]; then
        cp -f $resdir/jupiter-blend/resources/asr/models/default/latest/am/am.mvn $diskdir/nls-cloud-slp/asr/am/am.mvn
    fi

    if [ -d $resdir/asr/customlms ]; then
        if [ ! -d $diskdir/nls-cloud-slp/asr/customlms ]; then
            mkdir -p $diskdir/nls-cloud-slp/asr/
            cp -rf $resdir/asr/customlms $diskdir/nls-cloud-slp/asr/customlms
        fi
    fi
    
    if [ ! -d $diskdir/nls-cloud-slp/demo ]; then
        if [ -d $resdir/slp/demo ]; then
            cp -rf $resdir/slp/demo $diskdir/nls-cloud-slp/demo
        fi
    fi
}

function prepareComposeYml {
    echo "version: 'COMPOSE_VERSION'" > $COMPOSEFILE
    echo "services:" >> $COMPOSEFILE

    grep "avx2" /proc/cpuinfo > /dev/null
    if [ $? -ne 0 ]; then
      sed -i "s/app_appconfig_unifyPost_enable=true/app_appconfig_unifyPost_enable=false/g" $BASEHOME/conf/compose/nls-cloud-filetrans.yml
      grep "app_nls_cloud_realtime_common_unifyPost_enableVadUnifyPost" $BASEHOME/conf/compose/nls-cloud-realtime.yml  > /dev/null 2>&1
      if [ $? -ne 0 ]; then
          echo "      - app_nls_cloud_realtime_common_unifyPost_enableVadUnifyPost=false" >> $BASEHOME/conf/compose/nls-cloud-realtime.yml
          echo "      - app_nls_cloud_realtime_common_unifyPost_enablePost2ByDefault=false" >> $BASEHOME/conf/compose/nls-cloud-realtime.yml
      fi
    fi

    if [ ! -d /sys/fs/cgroup/cpuacct,cpu ]; then
        mount -o remount,rw '/sys/fs/cgroup'
        ln -s /sys/fs/cgroup/cpu,cpuacct /sys/fs/cgroup/cpuacct,cpu
    fi
        docker images | grep -v REPOSITORY | awk '{print $1}' > ./images.list

    suffix_gpu="-none"
    if [ -e "/dev/nvidiactl" ]; then
        log_info "[INFO] this machine support GPU!!!"
        suffix_gpu="-gpu"
        # gpu nvidia runtine need 2.3+
        COMPOSE_VERSION="2.3"
    fi

    #####准备yml文件
    #读取./images.list下的文件 先将apes容器相应信息写入docker compose文件中
    while read imageName
    do
        if [ $imageName != "apes" ]; then
            continue
        fi
        ps aux | grep -v grep | grep appctl | grep apes > /dev/null
        if [ $? -eq 0 ]; then
            log_info "发现用户外置启动非容器版Apes，容器版Apes将自动进入静默状态"
            continue
        fi
        # 增加apes ip比对，如果不是配置apesip 所在主机，就也忽略apes的启动
        ymlFile="$BASEHOME/conf/compose/$imageName.yml"
        cat $ymlFile | grep -v "^version" | grep -v "^services" >> $COMPOSEFILE
    done < ./images.list
#读取./images.list下的文件 将其他的容器相应信息写入docker compose文件中
    while read imageName
    do
        if [ $imageName == "apes" ]; then
            continue
        fi
        ymlGpuFile="$BASEHOME/conf/compose/${imageName}${suffix_gpu}.yml"
        ymlFile="$BASEHOME/conf/compose/${imageName}.yml"
        if [ -f "$ymlGpuFile" ]; then
            log_info "[INFO] service ${imageName} support GPU!!!"
            ymlGpuBakFile="$ymlGpuFile.bak"
            cp -f $ymlGpuFile $ymlGpuBakFile
            for devId in $(seq 0 30);
            do
                devPath="/dev/nvidia$devId"
                if [ -e "$devPath" ]; then
                    sed -i "/nvidiaN/a\      - \'$devPath:$devPath\'" $ymlGpuBakFile
                fi
            done
            sed -i "/nvidiaN/d" $ymlGpuBakFile
            cat $ymlGpuBakFile | grep -v "^version" | grep -v "^services" >> $COMPOSEFILE
            rm -f $ymlGpuBakFile
        elif [ -f "$ymlFile" ]; then
            cat $ymlFile | grep -v "^version" | grep -v "^services" >> $COMPOSEFILE            log_info "[INFO] cannot found compose file for $imageName, ignored"
        fi
    done < ./images.list
    sed -i "s/COMPOSE_VERSION/${COMPOSE_VERSION}/g" $COMPOSEFILE
}

echo "" > $StartLogFile

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
    echo "ERROR $@"  >> $StartLogFile
}

function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
    echo "INFO $@"  >> $StartLogFile
}

function log_warn() {
    echo -e "\033[33m [WARN] $@ \033[0m"
    echo "WARN $@"  >> $StartLogFile
}

# Get answer (y/n)
function get_answer() {
    echo
    while echo "$* (y/n)? "
    do
    read yn
    case $yn in
    [yY]) return 0 ;;
    [nN]) return 1 ;;
    *) echo please answer y or n ;;
    esac
    done
}
#检查系统相关信息  
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
    #uniq -c删除命令重复行
    log_info `cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c`
    CPUHZ=`cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c | awk '{print $8}' | awk -F 'G' '{print $1}'`
    if [ $(echo "$CPUHZ < 2.5"|bc) = 1 ]; then
        log_warn "CPU主频${CPUHZ}GHZ 低于2.50GHz, 性能将无法达到指标或应用可能无法成功启动"
    fi

    grep "avx2" /proc/cpuinfo > /dev/null
    if [ $? -ne 0 ]; then
        log_warn "CPU不支持AVX2指令集，性能将无法达到指标或应用可能无法成功启动"
        if get_answer "该机器CPU不支持avx2指令集，性能将无法达到预期，以及部分应用无法成功启动(比如tts、asr、自学习平台、unify-eas)， 请您再次确认是否继续安装，请选择y(继续)或者n(退出)"; then
            log_warn "重要风险提示：该机器CPU不支持avx2指令集，部分应用性能将无法达到预期目标，以及部分应用无法成功启动，但您选择了继续安装"
        else
            log_warn "部署即将退出，系由CPU不支持avx2指令集，建议选择支持avx2指令集的机器后再次部署"
            exit 0
        fi
     fi
    #       sed -i "s/app_appconfig_unifyPost_enable=true/app_appconfig_unifyPost_enable=false/g" $BASEHOME/conf/compose/nls-cloud-filetrans.yml
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
#-Sn设置软资源限制  -Hn设置硬资源限制
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

function generate_asr_tts_license() {
    APES_IP=`grep -w  apes_addrs $CONFIGFILE | grep -v '^#' | awk -F = '{print $2}' | sed 's/,/ /g'`
    echo 'apes列表：'$APES_IP
    APES_PORT=`grep -w  apes_port $CONFIGFILE | grep -v '^#' | awk -F = '{print $2}'`

    #####asr授权取值
        for i in $APES_IP
        do
            asr_license=`sudo curl -k -s --user admin:e363865bdcc7b3f7f09c98c6780620ef "$i:$APES_PORT/vipas/uapi/ctx" | $BASEHOME/bin/jq '.data' | $BASEHOME/bin/jq '.[] | select(.title == "语音识别") ' | $BASEHOME/bin/jq '.data' | $BASEHOME/bin/jq '.[] | select(.title == "最大连接数") | .value'| sed 's/\"//g'`

            if [ "$asr_license" != "" ]; then
                echo $i'节点获取到asr授权最大连接数为：'$asr_license
                break
            else
                echo $i"节点apes链接失败，尝试下一个IP......\n"
            fi
        done
    if [ "$asr_license" = "" ]; then
        echo 'apes链接全部失败，请检查是否未启动apes，请先启动apes或申请授权后再启动jupiter-blend容器， 如不需要ASR能力则忽略'
    else
        sed -i '/JUP_ATOM_PROCESSOR_COUNT/d' $BASEHOME/resource/jupiter-blend/conf/supervisor-atom-asr.conf
        echo "    JUP_ATOM_PROCESSOR_COUNT=$asr_license" >> $BASEHOME/resource/jupiter-blend/conf/supervisor-atom-asr.conf
    fi

    #####tts授权取值
    for i in $APES_IP
        do
            tts_license=`sudo curl -k -s --user admin:e363865bdcc7b3f7f09c98c6780620ef "$i:$APES_PORT/vipas/uapi/ctx" | $BASEHOME/bin/jq '.data' | $BASEHOME/bin/jq '.[] | select(.title == "语音合成") ' | $BASEHOME/bin/jq '.data' | $BASEHOME/bin/jq '.[] | select(.title == "最大连接数") | .value'| sed 's/\"//g'`
            if [ "$tts_license" != "" ]; then
                echo $i'节点获取到tts授权最大连接数为：'$tts_license
                break
            else
                echo $i"节点apes链接失败，尝试下一个IP......"
            fi
        done
    if [ "$tts_license" = "" ]; then
        echo 'apes链接全部失败(强制取值为1)，请检查是否未启动apes，请先启动apes或者申请授权后再启动nls-cloud-tts容器， 如不需要TTS能力则忽略'
        tts_license=1
    fi
    grep app_engine_ttsLicenseTotal $BASEHOME/conf/compose/nls-cloud-tts.yml > /dev/null 2>&1
    if [ $? -ne 0 ]; then
       echo " not exit tts_license"
       echo "      - app_engine_ttsLicenseTotal=$tts_license" >> $BASEHOME/conf/compose/nls-cloud-tts.yml
    else
       echo " exist tts_license"
       sed -i '/app_engine_ttsLicenseTotal/d' $BASEHOME/conf/compose/nls-cloud-tts.yml
       echo "      - app_engine_ttsLicenseTotal=$tts_license" >> $BASEHOME/conf/compose/nls-cloud-tts.yml
    fi
}

function wait_for_apes_running() {
    APES_IP=`grep -w  apes_addrs $CONFIGFILE | grep -v '^#' | awk -F = '{print $2}' | sed 's/,/ /g'`
    echo 'apes列表：'$APES_IP
    APES_PORT=`grep -w  apes_port "$CONFIGFILE" | grep -v '^#' | awk -F = '{print $2}'`
        apes_running="0"
    for i in $APES_IP
        do
            response_code=`curl  -k -s --user admin:e363865bdcc7b3f7f09c98c6780620ef --connect-timeout 3 --max-time 5 "$i:$APES_PORT/vipas/uapi/ctx" -o /dev/null -w %{http_code}`
            if [ X"$response_code" == X"200" ]; then
                echo "节点"$i":"$APES_PORT"的apes已启动"
                apes_running="1"
                break
            else
                echo "节点"$i":"$APES_PORT"的apes尚未启动， 尝试检查下一个节点"
            fi
        done
    if [ X"$apes_running" != X"1" ]; then
        echo "apes节点("$APES_IP"都没有启动，请保证apes先启动后再启动其他服务，当前部署已暂时退出"
        exit 1
    fi
}

function main {
    chmod +x $SHHOME/*

    cp -f $CONFIGFILE $BASEHOME/.env
    chmod +x $SHHOME/docker-compose

    if [ -d $BASEHOME/demo ]; then
        chmod +x $BASEHOME/demo/*.sh
    fi

    docker images > /dev/null 2>&1
    if [ $? -ne 0 ];then
        log_error "执行Docker命令失败"
        log_error "[可能原因1] Docker未启动， systemctl start docker.service"
        log_error "[可能原因2] 权限不够，使用sudo 或者 将该用户加入docker用户组 sudo gpasswd -a \${USER} docker"
        exit 1
    fi

    sysOptimzation

    docker images | grep nls-cloud > /dev/null
    if [ $? -ne 0 ];then
        $SHHOME/init.sh
    fi

    prepareComposeYml

    check

    parpareVolumeDirs

    prepareAiContainer
        prepareSLP

    wait_for_apes_running

    generate_asr_tts_license

cat << EOF
+-------------------------------------------------+
|                启动容器                          |
+-------------------------------------------------+
EOF

    export COMPOSE_HTTP_TIMEOUT=120

    $SHHOME/docker-compose -f $COMPOSEFILE up -d $@

    log_info "--重要消息，请关注--"
    log_info "[日志目录]: $NLSLOGDIR"
    log_info "[运行数据目录]: "$NLSDATADIR""
    log_info "注意 预计3分钟后可以通过\"sh $BASEHOME/bin/status.sh\" 查看各服务主端口状态"
    log_info "注意 预计3分钟后可以通过\"sh $BASEHOME/demo/demo.sh\" 进行自验证 "

    grep "ERROR" $StartLogFile | sed "s/ERROR//g" > $ErrorLogFile
    grep "WARN" $StartLogFile | sed "s/WARN//g" > $WarnLogFile

    while read line
    do
        log_warn $line 
    done < $WarnLogFile
    rm -f $WarnLogFile

    while read line
    do
        log_error $line 
    done < $ErrorLogFile
    rm -f $ErrorLogFile
}

main $@
    
    
    
    
        
            
    
    
    