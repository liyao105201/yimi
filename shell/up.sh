#!/bin/bash
path=/root/$file
file=init_pkg_WEB_AICALL_R
executesh=run.sh
ipaddr="172.17.214.13"
ali="rm-2zeh6696p3us0821a.mysql.rds.aliyuncs.com"
page="robotapi.emic.com.cn"

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
   
}
function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
    
}

read -p "版本号：" version
cat << EOF
+-------------------------------------------------+
         开始解压版本文件$version
+-------------------------------------------------+
EOF
tar -xzvf ${file}_$version.tgz
if [[ $? -ne 0 ]];then 
   log_error "输入的版本号不对，请查看最新的版本号"

fi
#cd ${path}_$version/shell
head -12 run.sh
cat << EOF
+-------------------------------------------------+
         原始执行文件$executesh
+-------------------------------------------------+
EOF
sed -n '/^SERVER_DB_LIST=/p' $executesh
cat << EOF
+-------------------------------------------------+
         修改数据库连接配置
+-------------------------------------------------+
EOF
log_info "sed -i 's/^SERVER_DB_LIST=^SERVER_DOMAIN_SYSTEM=/SERVER_DB_LIST=\"$ali\"/' $executesh"
sed -i 's/^SERVER_DB_LIST=[[:print:]]*/SERVER_DB_LIST='\"$ali\"'/' $executesh

cat << EOF
+-------------------------------------------------+
        原始配置文件$executesh    
+-------------------------------------------------+
EOF
sed -n '/^SERVER_CACHE_LIST=/p' $executesh
cat << EOF
+-------------------------------------------------+
       修改IP地址   
+-------------------------------------------------+
EOF
log_info "sed -i 's/^SERVER_CACHE_LIST=[[:print:]]*/SERVER_CACHE_LIST=\"$ipaddr\"/' $executesh"
sed -i 's/^SERVER_CACHE_LIST=[[:print:]]*/SERVER_CACHE_LIST='\"$ipaddr\"'/' $executesh
cat << EOF
+-------------------------------------------------+
        原始配置文件      
+-------------------------------------------------+
EOF
sed -n '/^SERVER_DOMAIN_SYSTEM=/p'  $executesh
sed -n '/^SERVER_DOMAIN_API=/p' $executesh
cat << EOF
+-------------------------------------------------+
        修改system api配置     
+-------------------------------------------------+
EOF
log_info "sed -i 's/^SERVER_DOMAIN_SYSTEM=[[:print:]]*/SERVER_DOMAIN_SYSTEM=\"$page\"/' $executesh "
log_info "sed -i 's/^SERVER_DOMAIN_API=[[:print:]]*/SERVER_DOMAIN_API=\"$page\"/'  $executesh"
sed -i 's/^SERVER_DOMAIN_SYSTEM=[[:print:]]*/SERVER_DOMAIN_SYSTEM='\"$page\"'/'  $executesh
sed -i 's/^SERVER_DOMAIN_API=[[:print:]]*/SERVER_DOMAIN_API='\"$page\"'/'  $executesh


