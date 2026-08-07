#!/bin/bash
path=/etc/supervisor
conf_supervisord=/etc/supervisor/supervisord.conf
function log_info() {
    echo -e "\033[36m [INFO] $@ \033[0m"
}
cat <<EOF
+-------------------------------------------------+
           安装supervisor准备
+-------------------------------------------------+
EOF
log_info "开始安装python-setuptools"
sleep 5
yum install python-setuptools -y
log_info "开始安装pip"
sleep 5
easy_install pip
cat <<EOF
+-------------------------------------------------+
           开始安装supervisor
+-------------------------------------------------+
EOF
sleep 5
pip install supervisor 

if [[ -d $path ]];then
   log_info "supervisor配置文件夹:$path"
else
   log_info "创建supervisor配置文件夹:$path"
   mkdir -p $path
fi


log_info "/etc/supervisor目录下生成配置文件"
echo_supervisord_conf>$conf_supervisord
sed -i '$d' $conf_supervisord
echo "files = /etc/supervisor/conf.d/*.ini" >>$conf_supervisord
log_info "修改配置文件:$conf_supervisord"
echo "sed -i 's/;port=127.0.0.1:9001/port=*:9002/' $conf_supervisord"
sed -i 's/;port=127.0.0.1:9001/port=*:9002/' $conf_supervisord
cat <<EOF >>$conf_supervisord
[prgram:alert_server]
command=/home/emi/AlertServer/ENV/bin/python alert_server.py;
directory=/home/emi/AlertServer;
autorestart=true;
stopasgroup=true;
redirect_stderr=true;
stdout_logfile=/var/log/supervisor/alertserver.log;
loglevel=info;
EOF
log_info "启动supervisor"
log_info "supervisord -c /etc/supervisor/supervisord.conf" 
supervisord -c /etc/supervisor/supervisord.conf