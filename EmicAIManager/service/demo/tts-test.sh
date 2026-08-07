#!/bin/bash
#
# @see
# ./tts_test.sh
# Keepwin100<hukaijun@emicnet.com>
#
script_path=$(cd `dirname $0`; pwd)
source "${script_path}/../bin/common.sh"

function main()
{
  cat << EOF
+-------------------------------------------------+
|                正在测试TTS状态                    |
+-------------------------------------------------+
EOF
  echo  "正在测试TTS[智能客服_静静] 压力值100"
  mkdir -p ${script_path}/voice/
  b=''
  for ((i=0;$i<=100;i+=2))
  do
      curl "http://${CONFIG_TTS_HOST}:${CONFIG_TTS_PORT}/tts/access_token=speech&language=zh&domain=1&voice_name=智能客服_静静&text=您好我是静静" > ${script_path}/voice/jingjing_$i.wav
      echo "Get[http://${CONFIG_TTS_HOST}:${CONFIG_TTS_PORT}/tts/access_token=speech&language=zh&domain=1&voice_name=智能客服_静静&text=您好我是静静]"
      printf "Testing:[%-50s]%d%%\r" $b $i
      sleep 0.1
      b=#$b
  done
  echo "Jingjing Test Done"
  b=''
  for ((i=0;$i<=100;i+=2))
  do
      curl "http://${CONFIG_TTS_HOST}:${CONFIG_TTS_PORT}/tts?access_token=speech&language=zh&domain=1&voice_name=智能客服_小金&text=您好我是小金" > ${script_path}/voice/xiaojin_$i.wav
      echo "Get[http://${CONFIG_TTS_HOST}:${CONFIG_TTS_PORT}/tts?access_token=speech&language=zh&domain=1&voice_name=智能客服_小金&text=您好我是小金]"
      printf "Testing:[%-50s]%d%%\r" $b $i
      sleep 0.1
      b=#$b
  done
  echo "Xiaojin Test Done"
  b=''
  for ((i=0;$i<=100;i+=2))
  do
      curl "http://${CONFIG_TTS_HOST}:${CONFIG_TTS_PORT}/tts?access_token=speech&language=zh&domain=1&voice_name=标准合成_邻家女声_娇娇&text=您好我是娇娇" > ${script_path}/voice/jiaojiao_$i.wav
      echo "Get[http://${CONFIG_TTS_HOST}:${CONFIG_TTS_PORT}/tts?access_token=speech&language=zh&domain=1&voice_name=标准合成_邻家女声_娇娇&text=您好我是娇娇]"
      printf "Testing:[%-50s]%d%%\r" $b $i
      sleep 0.1
      b=#$b
  done
  echo "Jiaojiao Done"

  echo "Please check dir in[${script_path}/voice/]"
}


main $@