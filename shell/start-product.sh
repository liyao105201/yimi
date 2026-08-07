server_start_path="/var/pbx/website/shell/server-start.sh"
/usr/sbin/php-fpm
#systemctl need docker run whith '--privileged=true'
#systemctl restart php74-php-fpm
#systemctl restart redis
#systemctl restart nginx
#/opt/remi/php74/root/usr/sbin/php-fpm
/usr/bin/redis-server /etc/redis.conf
/usr/sbin/nginx -c /etc/nginx/nginx.conf


#设置crontab
/usr/sbin/crond -i

chown www-data.www-data /var/pbx -R
chmod 777 /var/pbx -R

#start callback
if [[ -f ${server_start_path} ]];then
     echo  "正在启动回调"
     nohup sh ${server_start_path} ${JOIN_SERVICE} &
fi

while true; do sleep 1; done
