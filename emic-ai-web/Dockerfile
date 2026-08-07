FROM centos:7.4.1708
ARG VERSION=2.2
MAINTAINER Dream "<hukaijun@emicnet.com>"
#添加yum源
RUN yum install -y epel-release https://mirrors.aliyun.com/remi/enterprise/remi-release-7.rpm yum-utils

ADD nginx/nginx.repo /etc/yum.repos.d/nginx.repo

RUN yum-config-manager --enable remi-php74;\
yum  update;\
yum install -y netools php php-common php-mbstring php-mcrypt php-xml php-gd php-cli php-opcache php-fpm php-pdo php-mysqlnd php-intl php-devel php-pear httpd-devel php-pecl-redis.x86_64 libssh2 libssh2-devel nginx crontabs sox kde-l10n-Chinese gcc php-pecl-zip php-pecl-ssh2 php-pecl-swoole4 redis.x86_64 java-1.8.0-openjdk.x86_64;\

RUN pecl install ssh2-1.0 ;\
groupadd www-data;\
useradd -g www-data www-data;\
mv /etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf.bak;\
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak;\
mv /etc/php.ini /etc/php.ini.bak;\
rm -rf /var/cache/yum/*;\
mkdir -p /var/pbx/website;\
mkdir -p /var/pbx/tmp;\
mkdir -p /var/pbx/upload/robot;\
mkdir -p /var/lib/php/session;\
mkdir -p /var/lib/nginx;\
mkdir -p /var/log/nginx;\
mkdir -p /var/log/php-fpm;\
mkdir -p /etc/nginx/crt;\
chmod 755 /etc/nginx/crt -R;\
chown www-data.www-data /var/lib/php -R;\
chmod 777 /var/lib/php -R;\
chown www-data.www-data /var/lib/nginx -R;\
chmod 777 /var/lib/nginx -R;\
chown www-data.www-data /var/log/nginx -R;\
chmod 777 /var/log/nginx -R;\
chown www-data.www-data /var/log/php-fpm -R;\
chmod 777 /var/log/php-fpm -R;\
mkdir -p /run/php-fpm;\
localedef -c -f UTF-8 -i zh_CN zh_CN.utf8;\
chown www-data.www-data /var/pbx -R;chmod 777 /var/pbx -R;\
yum clean all
RUN yum install -y php-pecl-rdkafka5 librdkafka.x86_64 lftp
ADD www.conf /etc/php-fpm.d/www.conf
ADD php.ini /etc/php.ini
ADD redis.conf /etc/redis.conf
ADD ssh2.ini /etc/php.d/ssh2.ini
ADD start-product.sh /var/pbx
ADD website /var/pbx/website
ADD docker-entrypoint.sh /var/pbx
#ADD nginx /etc/nginx/
RUN mkdir -p /etc/nginx/conf.d ;\
    cp /var/pbx/website/shell/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf;\
    cp /var/pbx/website/shell/nginx/nginx.conf /etc/nginx/nginx.conf;\
    cp /var/pbx/website/shell/nginx/crt/* /etc/nginx/crt/
RUN  cp -rf /var/pbx/website/config /var/pbx/website/config_orgin \
     && chmod 777 /var/pbx/ -R
EXPOSE 10251
EXPOSE 10252

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone

ENV LC_ALL "zh_CN.UTF-8"

ENTRYPOINT ["/var/pbx/docker-entrypoint.sh"]

CMD ["/bin/bash","/var/pbx/start-product.sh"]
