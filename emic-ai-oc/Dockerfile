FROM centos:7.4.1708
MAINTAINER Dream

RUN groupadd emi \
    && useradd -g emi emi \
    && yum update -y \
    && curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py \
    && python get-pip.py \
#    && yum -y install python-pip \
#    && pip install --upgrade pip \
    && yum -y install gcc automake autoconf libtool make mysql-devel python-devel \
    && yum -y install epel-release crontabs\
    && pip install MySQL-python\
    && pip install supervisor \
    && pip install superlance \
    && yum -y remove gcc automake autoconf libtool make \
    && yum clean all
ADD src /home/emi/

RUN cat /home/emi/supervisord.conf > /etc/supervisord.conf \
    && mkdir -p /home/supervisor \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor.d \
    && mkdir -p /var/pbx/oc_conf \
    && mv /home/emi/sendEmail /usr/local/bin/ \
    && chmod +x /usr/local/bin/sendEmail \
#TIMEZONE
    && /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone \
    && cd /home/emi/pack \
    && tar -zxvf outcallserver.tar.gz -C ../ \
    && cp ../outcallserver ../TTSCacheServer -R \
    && rm /home/emi/outcallserver/TTSCacheServer -f \
    && rm /home/emi/outcallserver/run_ttscacheserver.sh -f \
    && rm /home/emi/TTSCacheServer/outcallserver -f \
    && rm /home/emi/TTSCacheServer/run_outcallserver.sh -f


RUN cp /home/emi/outcallserver/conf/callingrobot.config  /var/pbx/oc_conf/callingrobot.config \
    && chmod +x /home/emi/outcallserver -R \
    && chmod +x /home/emi/TTSCacheServer -R \
    && tar -xzf /home/emi/AlertServer.tar.gz -C /home/emi/ \
    && chmod +x /home/emi/AlertServer -R \
    && chmod +x /home/emi/cron -R \
    && ln -sf /home/emi/outcallserver/conf/callingrobot.config  /home/emi/TTSCacheServer/conf/callingrobot.config \
    && mkdir -p /var/tts_data/tts_cached \
    && chmod 777 /tmp -R

COPY start-product.sh /var/pbx
COPY docker-entrypoint.sh /var/pbx

EXPOSE 9009

ENTRYPOINT ["/var/pbx/docker-entrypoint.sh"]

CMD ["/bin/bash","/var/pbx/start-product.sh"]