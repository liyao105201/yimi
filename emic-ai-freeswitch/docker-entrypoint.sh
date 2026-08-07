#!/bin/bash

set -eo pipefail
shopt -s nullglob

#fs默认mount 目录有两个
# /etc/freeswitch
# /usr/share/freeswitch/sounds/en/us/callie/robot/

etc_config="/etc/freeswitch/"
INSTALL_TAG='/var/pbx/freeswitch.lock'
or_config='/etc/freeswitch_orgin/'
emic_cfg='/etc/freeswitch/autoload_configs/emic.conf.xml'
mrcp_cfg="/etc/freeswitch/mrcp_profiles/ali.xml"
acl_cfg="/etc/freeswitch/autoload_configs/acl.conf.xml"

if [[ ! -f ${INSTALL_TAG} ]];then
    echo "Install freeswitch start!"
    #首次安装会清理掉配置
    if [[ -d ${or_config} ]];then
        rm /etc/freeswitch/* -rf
        mkdir /etc/freeswitch/ -p
        mv -f /etc/freeswitch_orgin/* /etc/freeswitch/
        rm -rf /etc/freeswitch_orgin/
    fi
    cp /var/pbx/blank_700_ms.wav  /usr/share/freeswitch/sounds/en/us/callie/robot/
    #fs common config

    #setting default config
    sed -i '/mod_callcenter/a\    <load module="mod_emic"/>\n    <load module="mod_unimrcp"/>' /etc/freeswitch/autoload_configs/modules.conf.xml
    sed -i '/mod_unimrcp/a\    <load module="mod_tts_commandline"/>' /etc/freeswitch/autoload_configs/modules.conf.xml
    #event_socket
    sed -i 's/\:\:/0\.0\.0\.0/g' /etc/freeswitch/autoload_configs/event_socket.conf.xml
    sed -i 's/8021/8011/g' /etc/freeswitch/autoload_configs/event_socket.conf.xml
    sed -i 's/ClueCon/Emicnet123456/g' /etc/freeswitch/autoload_configs/event_socket.conf.xml
    sed -i '/password/a\    <param name=\"apply-inbound-acl\" value="esl_acl"/>' /etc/freeswitch/autoload_configs/event_socket.conf.xml
    #external
    sed -i '/sip_tls_version/a\    <param name=\"user-agent-string\" value=\"callcenter_robot_aliyun_vm_CentOS7.4/r40000\"/>' /etc/freeswitch/sip_profiles/external.xml
    sed -i '/user-agent-string/a\    <param name=\"bind-params\" value=\"transport=tcp\"/>' /etc/freeswitch/sip_profiles/external.xml
    sed -i '/sip\-trace/d' /etc/freeswitch/sip_profiles/external.xml
    sed -i '/debug/a\    <param name=\"sip-trace\" value=\"yes\"/>' /etc/freeswitch/sip_profiles/external.xml
    #acl
    sed -i '/\/network-lists/i\    <list name="esl_acl" default="deny">\n <node type="allow" cidr="172.17.0.1/32"\/>\n <node type="allow" cidr="172.17.0.2/32"\/>\n <node type="allow" cidr="127.0.0.1/32"\/>\n    </list>' /etc/freeswitch/autoload_configs/acl.conf.xml
    #switch
    sed -i 's/sessions-per-second[^<]*\/>/sessions-per-second" value="1000"\/>/g' /etc/freeswitch/autoload_configs/switch.conf.xml

    if [[ ! -z ${OC_SERVER_IP} ]];then
        echo "Setting outcallserver ip is ${OC_SERVER_IP}"
        sed -i 's/\"default-service-addr\"[^<]*\/>/\"default-service-addr\" value=\"'${OC_SERVER_IP}'\"\/>/g'  $emic_cfg
    fi
    if [[ ! -z ${FS_EXTEND_IP} ]];then
        echo "Setting freeswitch extend ip is ${FS_EXTEND_IP}"
        sed -i 's/\"rtp-ext-ip\"[^<]*\/>/\"rtp-ext-ip\" value=\"'${FS_EXTEND_IP}'\"\/>/g'  $mrcp_cfg
        sed -i 's/\"rtp-ip\"[^<]*\/>/\"rtp-ip\" value=\"'${FS_EXTEND_IP}'\"\/>/g'  $mrcp_cfg
        sed  -i '/esl_acl/a\      <node type=\"allow\" cidr=\"'${FS_EXTEND_IP}'/32\"\/>'   $acl_cfg
    fi
    if [[ ! -z ${FS_LOCAL_IP} ]];then
        echo "Setting freeswitch local ip is ${FS_LOCAL_IP}"
        sed -i 's/\"client-ip\"[^<]*\/>/\"client-ip\" value=\"'${FS_LOCAL_IP}'\"\/>/g'  $mrcp_cfg
    fi
    if [[ ! -z ${MRCP_IP} ]];then
        echo "Setting mrcp server ip is ${MRCP_IP}"
        sed -i 's/\"server-ip\"[^<]*\/>/\"server-ip\" value=\"'${MRCP_IP}'\"\/>/g'  $mrcp_cfg
    fi
    if [[ ! -z ${ACL_ALLOWED_IP} ]];then
        echo "Setting freeswitch allow  is ${ACL_ALLOWED_IP}"
        sed  -i '/esl_acl/a\      <node type=\"allow\" cidr=\"'${ACL_ALLOWED_IP}'/32\"\/>'   $acl_cfg
    fi
    touch ${INSTALL_TAG}
    echo "Install freeswitch success!"
fi
exec "$@"
