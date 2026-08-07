#!/bin/bash
#用户关闭防火墙，ipv6，修改指定配置文件
function log_info() {
    echo -e "\033[36m [INFO] $@ \033[0m"
}
version=`cat /etc/redhat-release |awk '{print $4}'|cut -d . -f1`
cat << EOF
+--------------------------+
         正在关闭防火墙
+--------------------------+
EOF
sleep 1
cat /etc/redhat-release|grep red >/dev/null 2>&1
if [[ $? -eq 0 ]];then
   systemctl stop firewalld
   log_info "已关闭防火墙"
fi
cat /etc/redhat-release|grep CentOS >/dev/null 2>&1
if [[ $? -eq 0 ]];then
   if [[ $version -gt 6 ]];then
      systemctl disable firewalld
      systemctl stop firewalld
      log_info "已关闭防火墙"
      sleep 1
   else
      chkconfig iptables off
      service iptables stop
   fi
fi
cat /proc/version|grep ky>/dev/null 2>&1
if [[ $? -eq 0 ]];then
   systemctl stop firewalld
   log_info "已关闭防火墙"
fi
cat /etc/issue|grep SUSE >/dev/null 2>&1
if [[ $? -eq 0 ]];then
   service SuSEfirewall2_setup stop
   service SuSEfirewall2_init  stop
   log_info "已关闭防火墙"
fi
cat << EOF
+---------------------------+
       正在检查selinux状态
+---------------------------+
EOF
sleep 1
selinux_status(){

   status=`cat /etc/selinux/config|grep -v "^# SELINUX"|grep -w SELINUX`
   if [[ "$status" != "SELINUX=disabled" ]];then
      log_info "正在修改：/etc/selinux/config 文件 "
      sed -i '/^SELINUX=/d' /etc/selinux/config
      sed -i "6aSELINUX=disabled" /etc/selinux/config
      sleep 1
      log_info "selinux状态：`sed -n '/^SELINUX=/p' /etc/selinux/config` "
      setenforce 0
      sleep 1
   else
      log_info "selinux状态正确 "
      log_info "selinux状态：`sed -n '/^SELINUX=/p' /etc/selinux/config` " 
   fi
   cmd=`getenforce`
   log_info "selinux当前状态：${cmd}"

}
selinux_status
cat << EOF
+---------------------------+
       正在禁止ipv6
+---------------------------+
EOF
sleep 1
forbid_ipv6(){
   num=`cat /etc/sysctl.conf |grep net.ipv6|wc -l`
   if [[ $num -eq 0 ]];then
      log_info "正在修改配置："/etc/sysctl.conf" "
      log_info "正在添加 "net.ipv6.conf.all.disable_ipv6 = 1" "
      echo "net.ipv6.conf.all.disable_ipv6 = 1" >>/etc/sysctl.conf
      log_info "正在添加 "net.ipv6.conf.default.disable_ipv6 = 1" "
      echo "net.ipv6.conf.default.disable_ipv6 = 1" >>/etc/sysctl.conf
      log_info "正在添加 "net.ipv6.conf.lo.disable_ipv6 = 1" "
      echo "net.ipv6.conf.lo.disable_ipv6 = 1" >>/etc/sysctl.conf
      log_info "disable ip6，ipv6已禁用"
      sysctl -p >/dev/null
   else
      log_info "ipv6已禁用"
   fi
}   
forbid_ipv6
cat << EOF
+---------------------------+
       正在环境配置优化
+---------------------------+
EOF
sleep 1
env_modify(){
   cat /etc/security/limits.conf |grep ^*|grep - >/dev/null
   if [[ $? -ne 0 ]];then
       log_info "正在修改配置文件：/etc/security/limits.conf"
       log_info "正在添加 "* - nproc 65535" "
       echo "* - nproc 65535" >>/etc/security/limits.conf
       log_info "正在添加 "* - sigpending 65535" "
       echo "* - sigpending 65535" >>/etc/security/limits.conf
       log_info "正在添加 "* - nofile 655350" "
       echo "* - nofile 655350" >>/etc/security/limits.conf
   else 
       log_info " "limits.conf" 文件正确，不需修改"
   fi
   log_info " 修改端口范围"
   sysctl -w net.ipv4.ip_local_port_range="10000 64000"
   cat /etc/security/limits.d/20-nproc.conf >/dev/null 2>&1
   if [[ $? -eq 0 ]];then
      cat /etc/security/limits.d/20-nproc.conf |grep ^*|grep 65535 >/dev/null 
      if [[ $? -ne 0 ]];then
         log_info "正在修改配置文件 20-nproc.conf"
         log_info "添加字符串： "* - nproc 65535" "
         echo "* - nproc 65535" >>/etc/security/limits.d/20-nproc.conf
      else
         log_info " "20-nproc.conf配置文件已有:* - nproc 65535 " "
      fi 
   else
      cat /etc/security/limits.d/90-nproc.conf  >/dev/null 2>&1 
      if [[ $? -eq 0 ]];then
         cat /etc/security/limits.d/20-nproc.conf |grep ^*|grep 65535 >/dev/null 
         if [[ $? -ne 0 ]];then
             log_info "正在修改配置文件 90-nproc.conf"
             log_info "添加字符串： "* - nproc 65535" "
             echo "* - nproc 65535" >>/etc/security/limits.d/90-nproc.conf
          else
            log_info " "90-nproc.conf配置文件已修改" "
         fi
      fi
     
   fi
}
env_modify
log_info "请退出当前登入终端,使配置生效"