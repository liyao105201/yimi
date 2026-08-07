# 易米外呼平台redis版本

基于 reids:7.0.0 适用于 EMIC_AI_INSTALL_V3

## 打包方法

```shell script
docker build -t emic-ai/redis:v22.6.1 .

docker save -o emic-ai-redis.v22.6.1.tar emic-ai/redis:v22.6.1
```

## 使用方式

### 启动容器
```shell script
docker run -itd --network=host --restart=unless-stopped  -v /etc/pbx/redis/:/etc/redis/ -e REDIS_PORT=16379 --name emic-ai-redis emic-ai/redis:v22.6.1
```
**注意：**
/etc/redis/redis.conf 表示主机redis配置文件 注意多服务的时候 请自行配置地址

REDIS_PORT 表示redis的端口

REDIS_REQUIREPASS 表示redis的密码

### 启动redis-cli
```shell script
docker exec -it emic-ai-redis redis-cli -h 127.0.0.1 -p 16379 -a greeisgood
```
**注意：**
端口和密码以启动配置为准


