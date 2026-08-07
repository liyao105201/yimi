#!/bin/bash
group=sftp
user=yimi
authUser=1
sftpDisk=/data/sftp
path=$sftpDisk/$user
updownpath=$path/upload
config=/etc/ssh/sshd_config
configbak=/etc/ssh/sshd_configbak

#脚本命令如下
setenforce 0 >/dev/null
function log_info() {
    echo -e "\033[36m [INFO] $@ \033[0m"
}

cat << EOF
+-------------------------------------------------+
    正在建立sftp组：$group
+-------------------------------------------------+
EOF
groupadd $group

cat << EOF
+-------------------------------------------------+
    正在建立sftp用户：$user
+-------------------------------------------------+
EOF
useradd -g sftp -s /bin/false $user

cat << EOF
+-------------------------------------------------+
    正在建立sftp用户密码：$authUser
+-------------------------------------------------+
EOF
echo $authUser | passwd --stdin $user
cat << EOF
+-------------------------------------------------+
    正在建立sftp文件夹：$path
+-------------------------------------------------+
EOF
if [[ ! -d $path ]];then
   log_info "正在建立sftp文件夹$path"
   mkdir -p $path
else 
    log_info "sftp文件夹已存在路径：$path"
fi
cat << EOF
+-------------------------------------------------+
    正在建立上传下载文件夹：$updownpath
+-------------------------------------------------+
EOF
if [[ ! -d $updownpath ]];then
   log_info "正在建立上传下载文件夹$updownpath"
   mkdir -p $updownpath
else 
    log_info "上传下载文件夹已存在 路径：$updownpath"
fi
cat << EOF
+-------------------------------------------------+
    正在指定sftp用户home目录：$path
+-------------------------------------------------+
EOF
usermod -d  $path  $user
cat << EOF
+-------------------------------------------------+
    正在文件夹设定权限
+-------------------------------------------------+
EOF
chown root:$group $path
chmod 755 $path
chown $user:$group $updownpath
chmod 755 $updownpath
cat << EOF
+-------------------------------------------------+
    正在修改配置文件：$config
+-------------------------------------------------+
EOF
log_info"备份配置文件至$configbak"
cp -rp $config $configbak
sed -i 's/^Subsystem[[:print:]]*/#&/g' $config
cat << EOF >>$config
Subsystem   sftp   internal-sftp    
Match Group $group   
ChrootDirectory $sftpDisk/%u
ForceCommand    internal-sftp    
AllowTcpForwarding no    
X11Forwarding no 
EOF
log_info "重启sshd服务"
systemctl restart sshd