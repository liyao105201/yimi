# EmicAIBuilder

智能外呼系统镜像包发布系统

 > 执行命令如下
 > build.sh [name] [version] [is_push]
 > name:组件名称，如oc fs web 或者 outcallserver freeswitch aicall
 > version:版本如v42.1.89789
 > is_push:是否推送到远端
 > 例子：
 > build.sh -m fs -t V3.5.1 -p 1 -f aaa.tar.gz 
 > 会生成 freeswitch:V3.5.1 的镜像

## 说明

本系统不兼容V2.X，2.x的版本需要进入各个开发model进行单独打包。
本系统的包采用统一的打包，统一安装，极致的减少人为操作。

## emic-ai-freeswitch

```shell
build.sh -m fs -t V3.5.2 -p 1 
#或者
build.sh -m freeswitch -t V3.5.2 -p 1 
```

## emic-ai-mysql
```shell

```
## emic-ai-redis

## emic-ai-web



## emic-ai-trimule

## emic-ai-nlp

## emic-ai-oc

```shell
build.sh -m oc -t V42.2.78122 -p 1 
#或者
build.sh -m outcallserver -t V42.2.78122 -p 1 
```


