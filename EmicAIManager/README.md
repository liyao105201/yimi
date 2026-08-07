# Emi_AI_Install V3.0

#### 介绍
智能外呼系统安装组件,本系统能完成智能外呼系统的安装与升级维护等操作。

#### 软件架构
本系统使用docker部署和维护。


#### 安装教程
智能外呼系统 V3.0安装指导

#1.解压软件#

```bash
mkdir -p /var/pbx
#将安装包上传到此
cd /var/pbx/
tar -czvf Emi_AI_Install_V3.X.tar.gz ./
```
#2. 环境检查#

验证该环境是否满足安装要求，我们需要最少32核、内存64GB和主频2.2GHz的服务器要求。
```bash
cd Emi_AI_Install_V3.X/service
./bin/report.sh
```
#3. 环境安装#

初始化docker环境
```bash
./bin/init.sh docker 
```

#4. 组件安装#

本系统依赖两个组件`mysql（5.7）`和`redis（4.2）`
```bash
./bin/init.sh mysql
./bin/init.sh redis 
```

#5. 服务安装#

```bash
./bin/start.sh
#默认情况下会自动安装 freeswitch aicall outcallserver
#如果服务是分开部署，需要指定服务
./bin/start.sh freeswitch
```

#6. 服务验证#

本程序可以验证服务是否启动，组件是否正常，因为无法注册，本程序做能做调试使用，进行外呼需要手动注册验证。

```bash
./test.sh
```

#### 使用说明

1. 升级版本
```bash
./bin/update.sh 
#重启
./bin/stop.sh
./bin/start.sh
#升级失败
./bin/reset.sh
```

#### 申明

1. 安装包下的文件不需要改， 
