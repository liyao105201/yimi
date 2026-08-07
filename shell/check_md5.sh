#!/bin/sh
SHHOME=$(cd `dirname $0`; pwd)
BASEHOME=$(cd $SHHOME/..; pwd)

if [ $# -lt 1 ]; then
    echo "usage: " $0 \<dir\> 
    echo "usage example: " $0 "asr|slp|realtime|ai-container|unify-post"
    exit
fi

function log_error() {
    echo -e "\033[31m [ERROR] $@ \033[0m"
}

function log_info() {
    echo -e "\033[32m [INFO] $@ \033[0m"
}

app=$1
if [ X$app == X"unify-post" ]; then
    filelist=$BASEHOME/resource/unify-post/unify-post.md5
elif [ X$app == X"slp" ]; then
    filelist=$BASEHOME/resource/slp/slp.md5
elif [ X$app == X"ai-container" ]; then
    filelist=$BASEHOME/resource/ai-container/ai-container.md5
elif [ X$app == X"realtime" ]; then
    filelist=$BASEHOME/resource/realtime/realtime.md5
elif [ X$app == X"asr" ]; then
    filelist=$BASEHOME/resource/asr/default/asr.md5
else
   log_error "输入参数：$app 不合法，不是正确的输入，比如可以输入 asr、slp、realtime、ai-container、unify-post"
   exit 1
fi


if [ ! -f "$filelist" ]; then
    log_error "$filelist 文件不存在，无法进一步校验资源完整性，已忽略后续校验"
    exit 1
fi

log_info "start check file,please wait(如果校验成功则不无报错信息)...."
log_info "开始校验 $BASEHOME/resource/$app 目录下的资源完整性"

res=`md5sum -c $filelist | grep FAIL`
if [ "$res" == "" ];then
   log_info "check OK, 校验成功"
else
   log_error "${res}"
   log_error "check FAIL, please check, 校验失败，如果提示文件不存在，请确保原始资源是否正确or误删除(可以手动解压对应的资源压缩包)"
   exit 1
fi
