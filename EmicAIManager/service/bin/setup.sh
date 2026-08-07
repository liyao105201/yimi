#!/bin/bash
script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
net_tools='net-tools-2.0-0.25.20131004git.el7.x86_64.rpm'
biz2_tools='bzip2-1.0.6-13.el7.x86_64.rpm' 
#进入脚本所在路径,${BASEHOME}为service路径
cd $EMICHOME
tools_path=${BASEHOME}/tools
images_path=${BASEHOME}/images
cat << EOF
+--------------------------+
    检查服务器相应配置
+--------------------------+
EOF
/bin/bash ./report.sh
cat << EOF
+--------------------------+
    修改服务器相应配置
+--------------------------+
EOF
/bin/bash ./optimize.sh
cat << EOF
+--------------------------+
    检查必要的软件安装
+--------------------------+
EOF
ifconfig >/dev/null 2>&1
if [[ $? -ne 0 ]];then
   cd $tools
   yum install ${net_tools} -y
fi
rpm -qa|grep tar >/dev/null 2>&1
if [[ $? -ne 0 ]];
   yum install ${biz2_tools} -y
fi

cd $images_path
ls -lrt|grep outcall_server >dev/null 2>&1
if [[ $? -eq 0 ]]:then
   log_error "缺少oc镜像tar包"
   exit
fi
ls -lrt|grep freeswitch >dev/null 2>&1
if [[ $? -eq 0 ]]:then
   log_error "缺少fs镜像tar包"
   exit
fi
ls -lrt|grep freeswitch >dev/null 2>&1
if [[ $? -eq 0 ]]:then
   log_error "缺少aicall镜像tar包"
   exit
fi
CONFIG_VERSION_OUTCALL_SERVER=`ls -lrt|grep outcall_server|awk '{print $NF}'|awk -F '.' -vOFS='.' '{print $2,$3,$4}'`
CONFIG_VERSION_AICALL=`ls -lrt|grep aicall|awk '{print $NF}'|awk -F '.' -vOFS='.' '{print $2,$3,$4}'`
CONFIG_VERSION_FREESWITCH=`ls -lrt|grep freeswitch|awk '{print $NF}'|awk -F '.' -vOFS='.' '{print $2,$3,$4}'`
cd $EMICHOME
/bin/bash ./start.sh aicall
/bin/bash ./start.sh freeswitch
/bin/bash ./start.sh outcall_server
choose = read - p '是否是私有化环境,是请输入:y,否请输入n'
sleep 3
if [[ $choose == 'y' ]]:then
    log_info "执行私有化oc配置修改脚本:fixinstall.sh"
    sleep 3
   /bin/bash ./fixinstall.sh
fi

