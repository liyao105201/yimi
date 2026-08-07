FROM centos:7.4.1708
MAINTAINER keepwin100 "hukaijun@emicnet.com"

ADD resource /root/resource

#freeswitch
RUN groupadd freeswitch \
    && useradd -g freeswitch freeswitch \
    && yum clean all \
    && echo "skyameny" > /etc/yum/vars/signalwireusername \
    && echo "pat_sdDvbaZYCGQ5CLbwY3gFvkkw" > /etc/yum/vars/signalwiretoken \
    && yum install -y https://$(< /etc/yum/vars/signalwireusername):$(< /etc/yum/vars/signalwiretoken)@freeswitch.signalwire.com/repo/yum/centos-release/freeswitch-release-repo-0-1.noarch.rpm epel-release \
    && yum install -y broadvoice \
    && yum -y update \
    && yum -y install gcc automake autoconf deltarpm libtool make mysql-devel python-devel crontabs python-pip \
    && yum install -y freeswitch-config-vanilla freeswitch-lang-* freeswitch-sounds-*

#操作
RUN mkdir -p /home/emi \
    #安装ldns
    && cd /root/resource/ \
    && curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py \
    && python get-pip.py \
#    && yum install ldns \
    && tar -zxvf ldns-1.7.0.tar.gz -C /home/emi/ \
    && tar -zxvf openssl-1.1.0c.tar.gz -C /home/emi/ \
    && cd /home/emi/openssl-1.1.0c \
    && mkdir openssl \
    && ./config --prefix=/home/emi/openssl-1.1.0c/openssl --openssldir=/home/emi/openssl-1.1.0c/ssl \
    && make -j16 \
    && make install \

    && cd ../ldns-1.7.0 \
    && ./configure --prefix=/home/emi/ldns-1.7.0/ldns --with-ssl=/home/emi/openssl-1.1.0c/openssl \
    &&  make -j16 \
    && make install \
#   supervisord
    && pip install --upgrade pip \
    && pip install supervisor \
    && pip install superlance \
    && mkdir -p /home/supervisor \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor.d \
    #supervisor config
    && cp /root/resource/supervisord.conf /etc/supervisord.conf \
    #&& echo_supervisord_conf > /etc/supervisord.conf \

    #link so file
    && cd /usr/lib64 \
    && ln -sf /home/emi/ldns-1.7.0/ldns/lib/libldns.so.2.0.0 libldns.so.1 \
    && ln -sf /home/emi/openssl-1.1.0c/openssl/lib/libcrypto.so.1.1 libcrypto.so.1.1 \
    && ln -sf /home/emi/openssl-1.1.0c/openssl/lib/libssl.so.1.1 libssl.so.1.1 \
    && ln -sf libjsoncpp.so.0.10.6 libjsoncpp.so \
    && ln -sf libjsoncpp.so.0.10.6 libjsoncpp.so.0 \
    && cd /usr/lib64/freeswitch/mod/ \

    #send mail
    && cp /root/resource/sendEmail /usr/local/bin/ \
    && chmod +x /usr/local/bin/sendEmail \

    #local time
    && /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone  \

    #clean env
    && yum clean all

#    && yum -y install gcc automake autoconf libtool make \
#    && yum -y install openssh-clients \
#    && yum -y install vim-enhanced \
#    && yum -y install wget \
#    && yum -y install gdb \
#    && yum -y install net-tools.x86_64 \

#freeswitch 安装配置
RUN mkdir /var/pbx \
    && cd /root/resource/ \
    #  Mod_emic #3.1.3
    && cp mod_emic.so mod_unimrcp.so mod_tts_commandline.so  /usr/lib64/freeswitch/mod/ \
    #  libjsoncpp
    && cp  libjsoncpp.so.0.10.6   /usr/lib64/ \
    #  emic.conf.xml mrcp base config
    && cp emic.conf.xml  unimrcp.conf.xml /etc/freeswitch/autoload_configs/ \
    #  yes_no.gram
    && cp yes_no.gram       /usr/share/freeswitch/grammar/ \
    # tts
    && cp  ali.xml tit.xml /etc/freeswitch/mrcp_profiles/ \
    && rm -rf /root/resource

COPY start-product.sh /var/pbx
COPY docker-entrypoint.sh /var/pbx
COPY resource/blank_700_ms.wav /var/pbx
#重命名默认的配置
RUN mv /etc/freeswitch /etc/freeswitch_orgin \
    && chmod 777 /var/pbx/ -R


ENTRYPOINT ["/var/pbx/docker-entrypoint.sh"]
CMD ["/bin/bash","/var/pbx/start-product.sh"]