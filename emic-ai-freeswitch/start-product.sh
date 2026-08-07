fs_pid='/var/run/freeswitch/freeswitch.pid'
supervisord -c /etc/supervisord.conf
#防止断电等意外操作
if [[ -f ${fs_pid} ]];then
  rm -f ${fs_pid}
fi
supervisorctl restart freeswitch
#必须加
while true; do sleep 1; done
