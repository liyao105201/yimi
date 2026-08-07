#!/bin/bash
#(完成oc容器内部程序替换.升级包需放在此路径下)
#请注意容器名称
function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
}
mkdir /etc/pbx/outcall_server_`date +%Y%m%d` -p
echo "正在备份配置文件路径:/etc/pbx/outcall_server_`date +%Y%m%d`"
cp /etc/pbx/outcall_server/* /etc/pbx/outcall_server_`date +%Y%m%d` -rp
echo "正在删除容器内部可能存在的tar包"
##-----####下面的名称根据实际修改
docker exec  outcallserver bash -c  'cd /home/emi;rm outcallserver.tar.gz reoc.sh -f'
echo "拷贝升级包至容器内部;/home/emi下"
##-----####下面的名称根据实际修改
docker cp outcallserver.tar.gz outcallserver:/home/emi
echo "拷贝升级脚本进容器内部"
##-----####下面的名称根据实际修改
docker cp reoc.sh outcallserver:/home/emi
echo "#----------------------------------------------------------------#"
log_info "--------------------生活愉快-----------------------"
log_info "         ！！！！！开始升级啦！！！！！！！        "
sleep 5
echo "#----------------------------------------------------------------#"
##-----####下面的名称根据实际修改
docker exec -it outcallserver bash -c 'cd /home/emi;sh reoc.sh'
