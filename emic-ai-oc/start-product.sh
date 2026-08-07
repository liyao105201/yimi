#/usr/sbin/nginx -c /etc/nginx/nginx.conf
#/usr/sbin/php-fpm
#/usr/bin/redis-server /etc/redis.conf
#chown www-data.www-data /var/pbx -R
##chmod 777 /var/pbx -R
supervisord -c /etc/supervisord.conf
#重启所有服务
supervisorctl restart all

while true; do sleep 1; done
