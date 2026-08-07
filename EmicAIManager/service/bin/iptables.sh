#!/bin/bash
# ali asr的安全要求
# 脚本禁止以下端口被非本机意外的机器访问
# @author HuKaijun<Hukaijun@emicnet.com>

iptables -I INPUT -p tcp --dport 8901 -j DROP
iptables -I INPUT -s 127.0.0.1 -p tcp --dport 8901 -j ACCEPT
iptables -I INPUT -p tcp --dport 8111 -j DROP
iptables -I INPUT -s 127.0.0.1 -p tcp --dport 8111 -j ACCEPT
iptables -I INPUT -p tcp --dport 9094 -j DROP
iptables -I INPUT -s 127.0.0.1 -p tcp --dport 9094 -j ACCEPT
iptables -I INPUT -p tcp --dport 8701 -j DROP
iptables -I INPUT -s 127.0.0.1 -p tcp --dport 8701 -j ACCEPT
iptables -I INPUT -p tcp --dport 9090 -j DROP
iptables -I INPUT -s 127.0.0.1 -p tcp --dport 9090 -j ACCEPT
iptables -I INPUT -p tcp --dport 9092 -j DROP
iptables -I INPUT -s 127.0.0.1 -p tcp --dport 9092 -j ACCEPT
iptables -I INPUT -p tcp --dport 8803 -j DROP
iptables -I INPUT -s 127.0.0.1 -p tcp --dport 8803 -j ACCEPT

