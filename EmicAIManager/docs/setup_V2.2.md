EMIAI_离线版本安装步骤V2.2(修订版)
======

> 作者：胡开军 <hukaijun@emicnet.com>
>
> 发布时间：2021年6月20日
> 
>审核：

修订版本：

|版本|作者|描述|
|---|---|
|v1.0|胡开军|创建文件

## 一.背景

1.本次修订，主要处理安装过程中用于环境优化的脚本和mysql以及redis的docker安装。

### 目标人群

 * AI项目开发者。
 * AI项目运维，测试人员。

### 使用须知

 本文档将介绍米话智能外呼系统的Docker版安装，不会对使用的技术做解释，如有疑问请自行wiki或咨询 

### 缩略词

 * 1)**WEB**：AI Web系统，用户平台配置使用等。
 * 2)**OC**：Outcall Server 完成对话管理、呼叫管理等功能。
 * 3)**FS**: FreeSwitch的简称，FS理解为pbx 软交机，用来完成机器人媒体业务。
 * 4)**ASR**：自动语音识别技术(Automatic Speech Recognition)是将人的语音转换为文本的技术。
 * 5)**TTS**：TTS是Text To Speech的缩写，即“从文本到语音”，是人机对话的一部分，让机器能够说话。

**清单1:服务器硬件要求**

处理器|内存|主频|硬盘|CPU
----|----|----|----|
至少16核|至少32G|2.5GHz|300G|支持AVX2

<center><font color=orange size=12>清单1.服务器硬件要求</font></center>

> **注意:**
>
> 为了保证ASR的授权稳定，我们最好使用真实物理机作为ASR的运行载体。
>
> 参考FAQ134

## 二.设计原理

我们汲取了前面进一年的实际实施的经验，本次设计采用了更为便捷的安装方式，原则上我们尽可能的简洁了高效，减少人为干预和手动配置。
> 新版本具有以下特点：
>* 1.安装简单高效。
>* 2.调试便捷，日志详细。
>* 3.自动化程度高,拥有高可用性，减少人为干预和维护。
>* 4.安装文件包较大，合计共50G左右，因此需要提前考虑。
>* 5.需要tts和asr的授权才能使用，也需要提前考虑。

### 2.1 逻辑结构设计

这一步，我们需要根据现有资源进行整合，根据客户需求，我们运筹出最合理的技术方案。这一步需要一定的技术数据做支持。
下面是一份根据提供的设备资源，整理的一份设计内容，如图所示样例。
![智能外呼系统-逻辑图](../images/install/智能外呼系统-江西电信逻辑图.png)

其中：
 * `OC`、`FS`和`AI_WEB`将会部署在同一台服务器上。
 * `ASR`、`MRCP`和`TTS`将使用现网环境 
 * 通常我们不要将`MRCP`和`AI_WEB`放在一起，二者都会使用nginx的80端口，如果真的需要，则自己配置。

### 2.2 物理设计图
![智能外呼系统-物理图](../images/install/智能外呼系统-江西电信物理图.png)

熟悉了总体逻辑和流程，我们能勾勒一副完整的系统结构，那些资源是可以共用现网，那些资源需要申请，我们都需要明确，以备提前准备，如申请tts，申请网络端口，申请license等。
剩下的就一个一个来完成吧。

### 2.3 网络设计
描述整个AI系统的网络设计方式。
本系统支持最小化安装，可以将本系统集成到一台主机上运行，如果不是这样，我们为了发挥系统的性能，建议我们使用一律使用内网。

#### 2.3.1 端口开放

端口|所属组件|是否需要开放|描述
----|----|----|---
18100|TTS|No|tts的http端口
13306|MySQL|No|数据库端口
16379|Redis|No|Redis端口
1171 |aicall|Yes|机器人HTTP端口[可配]
1172 |aicall|Yes|机器人HTTPS端口[可配]
9009或9010 |OC|No|外呼接口http(私有化多倾向9010)
8848 |FS|No|外呼服务TCP端口
7010 |ASR|No|外呼的ASR引擎端口

### 2.4 数据设计
本章节描述整个AI系统的数据设计，包含了数据存储和数据的安全等。

我们定义了统一的文档目录功能和规划

分类|路径|描述
----|----|----
项目主目录|/var/pbx/|机器人项目主要的内容都在这里
安装地址|/var/pbx/Emi_AI_Install_V2.X|程序安装的地址
日志|/var/pbx/logs/app|可以获取程序运行的日志 
程序数据|/var/pbx/lib/app|程序运行时数据 如docker
配置|/etc/pbx/|获取程序的配置项
脚本|/etc/pbx/scripts/|辅助脚本程序，定时器任务等

<center><font color=orange size=14>清单2.服务器目录划分规划</font></center>

## 三.安装实施步骤

### 3.1 资源确认
确认服务器资源CPU指令集 内存 硬盘大小，主频是否满足**清单1**的要求，确认各服务器的SSH登录密码。

**清单2**

账号|密码|评估
----|----|----
root|xxx|Pass
emi|xxx|Pass

<center><font color=orange size=14>清单3.服务器账户确认</font></center>

**清单3**

指标|期待|现有|评估
----|----|----|----
CPU核心|16核+|32核|Pass
内存|64G|64G|Pass
主频|2.5GHz|2.1GHz|N
指令集|avx2|avx2|N
硬盘|300G+|1T|Pass
OS|CentOS7.3+|CentOS7.4|Pass
带宽|1M+|内网|Pass

<center><font color=orange size=14>清单4.服务器硬件确认</font></center>

### 3.2 文件上传

U盘共有两个文件夹，将文件上传到对应的服务器上 直接上传到`/var/pbx/` 下
#### 目录一.**Emi_AI_Install_V2.X**
这个安装包可以完成以下组件

**基础环境验证**

本程序安装包能完成以下功能

使用`report.sh`和`env.sh`命令

> * 系统报告
> * 基础环境优化
> * 自动化运维功能

**基础组件安装**

使用`init.sh`命令

> * 安装基础软件 `Docker`
> * 安装基础软件 TTS  这里只能支持较旧的TTS版本

**AI基本组件管理**

使用`start.sh`命令

> * 安装基础软件 aiweb
> * 安装基础软件 freeswitch
> * 安装基础软件 outcall_server
> * 安装基础软件 Redis
> * 安装基础软件 Mysql 并初始化数据库

#### 目录二.**AliASR**

这个安装包可以完成以下组件

**ASR组件**

**TTS（阿里版本）组件**

该目录会以分段形式存储，便于传输
```shell script
cd /var/pbx/AliASR
cat asr.tar.bz2.a* | tar xj
#该步骤非常耗时，需要耐心等待，结束后你将得到一个完整的目录
```

#### 目录三.**DBTTS**

这个安装包可以完成以下组件

**TTS（标呗版本）组件**

请根据服务器网络和需求规划，分别上传到各个服务器的`/var/pbx/`目录下。

### 3.3 系统环境优化

在2.2的版本中采用optimize.sh脚本对3.3.1---3.3.4环境优化

借助脚本程序。

`optimize.sh`来完成。修改完成之后需要退出shell重新登录(使环境变量生效)

```shell
./bin/optimize.sh 
```

在以往的就版本，我们需要手动来操作，以下是手动操作的步骤

#### 3.3.1 关闭防火墙

```bash
systemctl disable firewalld
systemctl stop firewalld
```
#### 3.3.2 关闭selinux
```
#查看状态
getenforce
#临时关闭
setenforce 0 （如果不重启服务器，必须要敲这行命令）
```
**永久生效**
修改/etc/selinux/config 文件
将SELINUX=enforcing 改为 SELINUX=disabled

#### 3.3.3 禁用IPV6

修改网卡配置 /etc/sysconfig/network-scripts/ 修改 IPV6INIT=no

```bash
systemctl disable ip6tables.service
sysctl -p

```
#### 3.3.4 环境配置优化

1）修改文件`/etc/security/limits.conf` 添加或者修改
```shell 

* - nproc 65535
* - sigpending 65535
* - nofile 655350
```
2）打开文件路径：`/etc/security/limits.d/20-nproc.conf`，可能会为`90-nproc.conf`，以实际为准，修改如下：

```shell
* - nproc 65535
```

**注意**

修改完成之后需要退出shell重新登录

### 3.4 安装组件

#### 3.4.1 概述

我们系统私有化部署使用的组件如下

第三方组件

**1.ASR**
**2.TTS（标贝）**

公共服务组件

**3.MySQL**
**4.Redis**
**5.Docker基础环境**

AI服务组件

**6.Outcall_server**
**7.Freeswitch**
**8.aicall**

扩展组件

**9.NFS（用于量大的多物理机操作）**

以下我们将系统的安装以上服务组件和基础环境

#### 3.4.2 安装Docker  

#### （fdisk -l看系统的挂盘情况 先挂盘！！！！！）

docker作为本系统的基础环境，ASR/TTS/AI服务都需要此环境。因此这是第一步。（先修改配置文件）

```shell script
cd /var/pbx/Emi_AI_install_V2.2/service
./bin/init.sh docker
```

**维护操作**

```shell script
systemctl start docker #启动
systemctl stop docker  #关闭
systemctl restart docker #重启
```

####3.4.2 安装Redis

redis作为系统的核心部件，2.2版本之前是原生态安装 2.2版本采用docker安装方式

```shell script
cd /var/pbx/Emi_AI_install_V2.2/service
./bin/init.sh redis
```

**维护操作**

```shell script
ps -ef|grep redis #查看是否启动
docker stop redis
docker start redis
docker restart redis
（代码待实现）
```

####3.4.3 安装组件MySQL

备注：可能存在需要修改配置文件情况（配置文件中的端口改成13306 密码123456前加@）

```shell script
cd /var/pbx/Emi_AI_install_V2.2/service
./bin/init.sh mysql
```

docker ps查看到mysql容器，且进入容器后

mysql -uroot -p'Sinicnet@123456'可以进入mysql命令行， 



ps -ef|grep mysql#验证msyql是否成功



####3.4.4 安装系统组件

AI系统组件我们目前只认为包括 OC（outcall_server） WEB（aicall）FS（freeswitch）三个组件。统称机器人

**修改配置**

```
vi service/conf/emic_ai.conf
```
配置项很多，具体参考源文件，有详细的描述，这里我们只做最简单的配置

通用配置
```
#fs所在的freeswitch的IP
freeswitch_server_host=172.17.214.17
#outcallserver所在的IP
outcall_server_host=172.17.214.17
#aicall所在的IP
aicall_server_host=172.17.214.25
#tts所在的IP
tts_server_host=192.168.2.29
#mysql的IP
mysql_server_host=rm-2ze4h4gd92r731iapeo.mysql.rds.aliyuncs.com
#redis的IP
redis_server_host=172.17.214.17
#asr的IP
asr_server_host=127.0.0.1

#版本信息
#版本号需要与images目录中的文件对应
#aicall的版本
version_aicall=r3.38.75902
#oc的版本
version_outcall_server=r3.38.74789
#fs的版本
version_freeswitch=r3.22.69851
#nlp的版本（私有化不用）
version_nlp=r3.22.00000

#data version 用于初始化数据 根据版本来的
version_data=75902

#tts类型选择 可选为"a"(阿里) or "b"（标贝）
tts_type = "a"
```

>**[info]注意:**
>
>其他项目无需改动，或者咨询<hukaijun@emicnet.com>。

**安装操作**

```shell script
cd /var/pbx/Emi_AI_install_V2.2/service
./bin/start.sh aicall
./bin/start.sh outcall_server
./bin/start.sh freeswitch
```

安装的版本会根据配置文件来定的。

outcall_server进入容器里修改/var/pbx/start-product.sh

supervisord -c /etc/supervisord.conf
sleep 3（加入这行）
#重启所有服务
supervisorctl restart all

否则exit后，docker restart container_id，进入容器查找服务时会失败

**维护操作**

服务启动与关闭

```shell script
docker stop aicall
docker start aicall
docker restart aicall
#fs和oc 同理
```

查看安装日志

```bash
less /var/pbx/logs/manager.log 
```

服务日志
```bash
/var/pbx/logs/aicall
/var/pbx/logs/freeswitch
/var/pbx/logs/outcall_server
```

服务配置
```bash
/etc/pbx/logs/aicall
/etc/pbx/logs/freeswitch
/etc/pbx/logs/outcall_server
```

**验证操作**

```shell script
docker ps #查看是否启动成功
ps -ef |grep freeswitch #验证freeswitch是否成功
ps -ef |grep nginx #验证aicall是否成功
ps -ef |grep outcall #验证oc是否成功
```
**注意**

由于部分组件无法直接运行，所以需要等到整个系统安装完成后使用试呼验证。

#### 3.4.4 安装标贝TTS服务

解压文件到`/var/pbx/db-tts`

**机器码生成**

使用机器码程序， 生产hardware.info，提供给项目经理，协调获取激活文件，需要将激活文件导入系统重启即可。

**安装软件**

```shell script
#导入镜像
sh load.sh images/biaobei-tts.tar
#启动容器@MAKR
sh run.sh 镜像 ID
#验证是否成功
docker ps |grep biaobei-tts
#查看服务
docker exec -it biaobei-tts /bin/bash
#查看状态
supervisorctl status
#退出容器
exit
```

**注意**

本容器会启动mrcp服务，asr服务，因此需要将它不启动，修改`run.sh`文件，把有mrcp的行注释即可。

测试

```shell script
sh ./test/test-http-restapi.sh
```

#### 3.4.4 安装（阿里）ASR-TTS服务

**1.安装apes授权服务**

cd /var/pbx/AliASR
cat asr.tar.bz2.a* | tar xj  (2.8版本的ASR文件很大 解压需要25分钟左右)

获取激活码

```shell script
cd /var/pbx/AliASR/V2.8.0/service
chmod +x ./bin/*
./bin/apes.sh start
./bin/apes.sh get > asr-info.txt
```
将上面获取的`asr-info.txt`机器码文件交给项目经理，
由他协调获取服务器的asr激活码`license.txt`。

**注意**

如果获取了asr-info，必须保证再激活之前不得重启服务

如果激活了apes，不得更新服务器硬件配置，如cpu、内存和网卡等。

激活APES

```shell script
./bin/apes.sh put 你的激活码  #你的激活码就是上面项目经理给的license.txt文件中的内容
#执行以后你可以看到asr激活情况
#使用ctx还可以查询激活情况
./bin/apes.sh ctx 
```

**1.安装ASR-TTS服务**

apes 激活成功后，我们开始安装TTS和ASR服务。

 ```shell script
#初始化
./bin/init.sh  （由于解压原因这步会需要很长时间大概5分钟，等就行了，）一直等到让你选择。    选择 all
#启动
./bin/start.sh  过5分钟之后执行下一步（服务器端口开放需要时间）


**注意：**
应用理论上在五分钟内即可启动成功

验证

```shell script
sh ./bin/status.sh
sh ./demo/demo.sh #选1，3，8 出现cuccess就可以了
```


### 系统性验证

#### 注册机器人
登录到es的系统管理员后台

点击系统配置
设置机器人的IP地址，端口为9009，协议为http

点击企业管理
选中企业点击开启机器人按钮，填写必要信息，保存，显示保存成功即可。


试呼

### 交付项目组

#### 完成部署文档
#### 完成交付文档

#### 完成运维文档





