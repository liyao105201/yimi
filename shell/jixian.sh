#!/bin/bash
current_user=zxadmin
passwd_file=/etc/pam.d/system-auth
sys_conf=/etc/sysctl.conf
allow_conf=/etc/hosts.allow
deny_conf=/etc/hosts.deny 
limit_conf=/etc/security/limits.conf
log_file1=/etc/rsyslog.d/listen.conf
log_file2=/var/log/boot.log
# ip_allow=172.21.183
function log_info() {
    echo -e "\033[36m [INFO] $@ \033[0m"
}
cat << EOF
+--------------------------+
      修改口令锁定策略
+--------------------------+
EOF
log_info "正在备份策略的配置文件${passwd_file}"
cp -p ${passwd_file} ${passwd_file}_bak
log_info "正在修改配置文件${passwd_file}"
sed -i 's/^auth[ ]*required[[:print:]]*/auth        required      pam_tally2.so deny=5 unlock_time=300 even_deny_root root_unlock_time=10/g' ${passwd_file}
sed -i 's/^account[ ]*required[[:print:]]*/account     required      pam_tally2.so/g' ${passwd_file} 
cat << EOF
+--------------------------+
         配置NTP 
+--------------------------+
EOF
log_info "开启时间服务"
systemctl start ntpd
cat << EOF
+--------------------------+
     去除目录写权限
+--------------------------+
EOF
for PART in `grep -v ^# /etc/fstab | awk '($6 != "0") {print $2 }'`
do
    find $PART -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -xdev -exec ls -ld {} \;>> fix_directory.txt 2>>/dev/null
done
if [[ -e fix_directory.txt ]];then
log_info "有目录需修改写权限"
  for directory in `cat fix_directory.txt`;
    do
      chmod o-w ${directory}
      
    done
  rm fix_directory.txt
else  
   log_info "无目录需修改写权限"
fi
cat << EOF
+--------------------------+
     去除文件写权限
+--------------------------+
EOF
chmod -R o-w /etc/pbx/aicall/*
cat << EOF
+--------------------------+
     修改640日志文件权限
+--------------------------+
EOF
log_info "正在对权限大于640的日志文件赋予640权限 ${log_file1} ,${log_file2}"
chmod 640 ${log_file1} ${log_file2}
cat << EOF
+--------------------------+
      修改安全日志文件
+--------------------------+
EOF
log_info "修改安全日志文件:etc/rsyslog.conf"
cat /etc/rsyslog.conf|grep '^*.err;kern.debug;daemon.notice /var/adm/messages'
if [[ $? -ne 0 ]];then
  echo "*.err;kern.debug;daemon.notice /var/adm/messages">>/etc/rsyslog.conf
fi
touch /var/adm/messages
chmod 640 /var/adm/messages
systemctl restart rsyslog
cat << EOF
+--------------------------+
      禁止IP路由转发
+--------------------------+
EOF
log_info "修改IP路由转发文件${sys_conf}"
cp -p ${sys_conf} ${sys_conf}._bak
cat ${sys_conf}|grep -w  '^net.ipv4.ip_forward = 0'
if [[ $? -ne 0 ]];then
  log_info ""${sys_conf}"文件追加"net.ipv4.ip_forward = 0" "
  echo "net.ipv4.ip_forward=0" >> ${sys_conf}
fi
sysctl -p
cat << EOF
+--------------------------+s
      控制远程访问的IP地址
+--------------------------+
EOF
log_info "正在备份${allow_conf},${deny_conf} "
cp -p ${allow_conf} ${allow_conf}._bak
cp -p ${deny_conf}  ${deny_conf}._bak
log_info "正在追加允许的IP地址至${allow_conf}"
log_info "正在追加限制的IP地址至${deny_conf}"
echo "sshd:ALL">>${allow_conf}
# echo "all:all">>${deny_conf}

cat << EOF
+--------------------------+
     系统core dump状态
+--------------------------+
EOF
cat ${limit_conf}|grep '^*[ ]*soft'>>/dev/null
if [[ $? -ne 0 ]];then
    log_info  "追加 "* soft core 0"，"* hard core 0"到文件${limit_conf}"
    echo "* soft core 0">>${limit_conf}
    echo "* hard core 0">>${limit_conf}
else
    log_info "系统core dump状态正常"
cat << EOF
+--------------------------+
     设置关键文件的属性
+--------------------------+
EOF
log_info "执行命令"chattr +a /var/log/messages""
chattr +a /var/log/messages 
cat << EOF
+--------------------------+
    对root为ls、rm设置别名
+--------------------------+
EOF
log_info "正在对环境配置文件.bashrc追加 alias ls='ls -aol'   alias rm='rm -i' "
su ${current_user}
cat ~/.bashrc|grep 'alias ls'>>/dev/null
if [[  $? -ne 0 ]];then
   echo " alias ls='ls -aol' " >> ~/.bashrc
fi
cat ~/.bashrc|grep 'alias rm'>>/dev/null
if [[  $? -ne 0 ]];then
   echo " alias rm='rm -i' " >> ~/.bashrc
fi
