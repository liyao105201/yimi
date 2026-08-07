#!/bin/bash
#pip install
echo -e "pip install\n"
yum -y install epel-release
yum -y install python-pip
pip install --upgrade pip

#supervisor install
echo -e "supervisor install\n"
pip install supervisor
echo_supervisord_conf > /etc/supervisord.conf
mkdir -p /home/supervisor
mkdir -p /var/log/supervisor
mkdir -p /etc/supervisor.d


#superlance install
echo -e "superlance install\n"
pip install superlance

#sendEmail install
echo -e "sendEmail install\n"
wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
tar -xzvf sendEmail-v1.56.tar.gz
cd sendEmail-v1.56
mv sendEmail /usr/local/bin/
chmod +x /usr/local/bin/sendEmail
