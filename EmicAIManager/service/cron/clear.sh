#!/bin/bash
# @author Hukaijun@emicnet.com
# 定时清理指定目录的日志
# run script at 1:00 every day witch root
# 0 1 * * * * /etc/pbx/script/clear.sh

#配置清理路径
data_dir='/var/pbx/logs'
voice_dir="/var/pbx/upload/robot/tts_cached"

find $data_dir -mtime +15 -name "*.log*"  -exec rm -f {} \;
find $voice_dir -mtime +180 -name "*.wav"  -exec rm -f {} \;

