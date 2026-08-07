#!/bin/bash
##读取服务器报告
# @author HuKaijun<Hukaijun@emicnet.com>

## 示例
## ./report.sh

script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
cd $EMICHOME
pwd
#环境检查
#要求纯净环境 4G内存+ 4核CPU+ CentOS7.3+
function env_check()
{
    TEST_FLAG=0
    #操作系统检查
    log_info "[系统内核版本]"
    log_info `uname -a`
    if [ -f /etc/redhat-release ];then
        os_version=`cat /etc/redhat-release|sed -r 's/.* ([0-9\.]+)\..*/\1/'|sed "s/\s//g"`
        log_info $os_version
        mos_version="7.3"
        if [ `echo "$os_version > $mos_version"|bc` -eq 1 ];then
            os_check="OK"
        else
            os_check="Failed"
        fi
        os_version="CentOS ${os_version}"
    else
        os_version="Unknown"
        os_check="Failed"
    fi
    #CPU检查
    cpu_info=`cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c`
    cpu_num=`cat /proc/cpuinfo | grep processor | wc -l`
    cpu_hz=`cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c | awk '{print $8}' | awk -F 'G' '{print $1}'`
    #指令集
    cpu_aux=`cat /proc/cpuinfo |grep avx2|wc -l`
    if [[ $? -ne 0 ]];then
        log_error "cpu没有avx指令集,可能导致服务无法正常运行"
        exit
    else
        log_info "cpu指令集正常"
    fi
    if [[ ${cpu_num} -lt 4 ]]; then
        cpu_check="Failed"
        log_warn "CPU核心少于4核，可能导致服务无法正常运行"
        exit
    else
        cpu_check="OK"
    fi
    #内存
    mem_size=`free -m | grep "Mem"  | awk '{print $2}'`
    if [ $mem_size -lt 4000 ];then
        mem_check="Failed"
        log_error "内存小于4G，可能导致服务无法正常运行"
        exit
    fi
    #硬盘
    disk_size=`df -hl /var/pbx/ | awk 'NR==2{print $2}' | sed 's/G//g'`
    if [[ $disk_size -lt 200 ]];then
        disk_check="Failed"
        log_error "硬盘大小不小于200G，可能导致服务无法正常运行"
        ex
    fi
    #软件

	docker ps >/dev/null 2>&1
	if [[ $? -ne 0 ]];then
		log_warn "no docker"
		docker_status='not install'
		docker_check='ERROR'
    else
        docker_status='OK'
	    docker_check='OK'
	fi

	which  mysql  >/dev/null 2>&1
	if [[ $? -ne 0 ]];then
		log_warn "no mysql"
		mysql_status='not install'
		mysql_check='ERROR'
    else
        mysql_status='OK'
	    mysql_check='OK'  
	fi

	whereis redis| grep redis >/dev/null 2>&1
	if [[ $? -ne 0 ]];then
		log_warn "no redis"
		redis_status='not install'
		redis_check='ERROR'
    else
       	redis_status='OK'
	    redis_check='OK'
	fi
	# systemctl stop firewalld.service
	# systemctl disable firewalld.service
	# selinux_status='OK'
	# selinux_check='OK'
    #端口
	netstat -ano   | grep -w '1171'
	if [[ $? -ne 0 ]];then
		log_warn "no 1171"
		port_1171_status='ERROR'
		port_1171_check='ERROR'
    else
    	port_1171_status='OK'
	    port_1171_check='OK'
	fi


	netstat -ano   | grep -w '1172'
	if [[ $? -ne 0 ]];then
		log_warn "no 1172"
		port_1172_status='ERROR'
		port_1172_check='ERROR'
    else
       	port_1172_status='OK'
	    port_1172_check='OK'
	fi

	netstat -ano   | grep -w '16379'
	if [[ $? -ne 0 ]];then
		log_warn "no 16379"
		port_16379_status='ERROR'
		port_16379_check='ERROR'
    else
        port_16379_status='OK'
	    port_16379_check='OK'
	fi

	netstat -ano   | grep -w '13306'
	if [[ $? -ne 0 ]];then
		log_warn "no 13306"
		port_13306_status='ERROR'
		port_13306_check='ERROR'
    else
       	port_13306_status='OK'
	    port_13306_check='OK'
	fi

   cat << EOF
+-------------------------------------------------+
                  服务器检查报告
      ---硬件检查---
      CPU          ${cpu_num}核 ${cpu_hz}GHz      ${cpu_check}
      Mem          ${mem_size}MB                  ${mem_check}
      Work_Path    ${disk_size}GB                 ${disk_check}
      OS           ${os_version}                  ${os_check}
      ---软件检查---
      Docker       ${docker_status}               ${docker_check}
      Mysql        ${mysql_status}                ${mysql_check}
      Redis        ${redis_status}                ${redis_check}
      ---端口检查---
      1171         ${port_1171_status}            ${port_1171_check}
      1172         ${port_1172_status}            ${port_1172_check}
      16379        ${port_16379_status}           ${port_16379_check}
      13306        ${port_13306_status}           ${port_13306_check}

    软件检查error可后续安装,可跳过。端口未启动可能服务未安装导致,可跳过
+-------------------------------------------------+
EOF

if [[ $TEST_FLAG == 1 ]]; then
    log_info "系统尚不能初始化，请仔细检查检查报告!"
    exit 1
fi
log_info "检查完毕,请检查脚本输出！"
}

env_check