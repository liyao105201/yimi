# emic-ai/freeswitch

## 更新

1.V3 更新的fs的版本 11

2.修正了BUG：
* 配置文件不正确
* acl文件不正确

## 编译命令
docker build -t freeswitch:3.5.1 .

## 安装指令

### 方法一.原生安装
```bash
#使用docker-compose
docker compose up
#使用基础命令

```

### 方法二.使用安装器
```bash
./bin/start.sh freeswitch
```




