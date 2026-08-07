#!/bin/bash
script_path=$(cd `dirname $0`; pwd)
source ${script_path}/common.sh
analysis_patch=$BASEHOME/src/base/analysis

function initPathAndConf() {
    log_info "开始初始化相关目录和权限"
    mkdir -p $CONFIG_CONF_PATH/java/config
    mkdir -p $CONFIG_CONF_PATH/java/fs
    mkdir -p $CONFIG_CONF_PATH/java/tmp
    mkdir -p $CONFIG_CONF_PATH/java/elasticsearch/data
    mkdir -p $logsdir/java/elasticsearch/logs
    mkdir -p $CONFIG_CONF_PATH/java/elasticsearch/config
    echo "cp -f $analysis_patch/elasticsearch.yml $CONFIG_CONF_PATH/java/elasticsearch/config/"
    cp -f $analysis_patch/elasticsearch.yml $CONFIG_CONF_PATH/java/elasticsearch/config/
    echo "cp -f $analysis_patch/log4j2.properties  $CONFIG_CONF_PATH/java/elasticsearch/config/"
    cp -f $analysis_patch/log4j2.properties $CONFIG_CONF_PATH/java/elasticsearch/config/
    echo "cp -f $analysis_patch/elasticsearch.sh $CONFIG_CONF_PATH/java/elasticsearch/config/"
    cp -f $analysis_patch/elasticsearch.sh  $CONFIG_CONF_PATH/java/elasticsearch/config/
    echo "cp -f $analysis_patch/application.properties $CONFIG_CONF_PATH/java/config/"
    cp -f $analysis_patch/application.properties $CONFIG_CONF_PATH/java/config/
    chmod -R 775 $CONFIG_CONF_PATH/java/elasticsearch/
    chmod -R 775 $logsdir/java/elasticsearch/logs
    chown -R 1000:1000 $CONFIG_CONF_PATH/java/elasticsearch/
    log_info "完成初始化相关目录和权限"
}

function startElasticsearch() {
    log_info "启动 elasticsearch 镜像"
    docker run -itd --name elasticsearch --network host --restart=unless-stopped \
    -v $CONFIG_CONF_PATH/java/elasticsearch/data:/usr/share/elasticsearch/data \
    -v $logsdir/java/elasticsearch/logs:/usr/share/elasticsearch/logs \
    -v $CONFIG_CONF_PATH/java/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
    -v $CONFIG_CONF_PATHE/java/elasticsearch/config/log4j2.properties:/usr/share/elasticsearch/config/log4j2.properties \
    -e "discovery.type=single-node" registry.cn-beijing.aliyuncs.com/tutorial/analysis-elasticsearch:$CONFIG_VERSION_ELASTICSEARCH
    log_info "正在启动 elasticsearch 镜像中"
    sleep 90
    log_info "完成启动 elasticsearch 镜像"
}

function startElasticsearchHostMode() {
    log_info "启动 elasticsearch 镜像"
    docker run -itd --name elasticsearch --restart=unless-stopped --network host \
    -v $CONFIG_CONF_PATH/java/elasticsearch/data:/usr/share/elasticsearch/data \
    -v $logsdir/java/elasticsearch/logs:/usr/share/elasticsearch/logs \
    -v $CONFIG_CONF_PATH/java/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
    -v $CONFIG_CONF_PATH/java/elasticsearch/config/log4j2.properties:/usr/share/elasticsearch/config/log4j2.properties \
    -e "discovery.type=single-node" registry.cn-beijing.aliyuncs.com/tutorial/analysis-elasticsearch:$CONFIG_VERSION_ELASTICSEARCH
    log_info "正在启动 elasticsearch 镜像中"
    log_info "正在执行：docker run -itd --name elasticsearch --network host --restart=unless-stopped \
    -v $CONFIG_CONF_PATH/java/elasticsearch/data:/usr/share/elasticsearch/data \
    -v $logsdir/java/elasticsearch/logs:/usr/share/elasticsearch/logs \
    -v $CONFIG_CONF_PATH/java/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
    -v $CONFIG_CONF_PATHE/java/elasticsearch/config/log4j2.properties:/usr/share/elasticsearch/config/log4j2.properties \
    -e "discovery.type=single-node" registry.cn-beijing.aliyuncs.com/tutorial/analysis-elasticsearch:$CONFIG_VERSION_ELASTICSEARCH"
    sleep 90
    log_info "完成启动 elasticsearch 镜像"
}

function confElasticsearch() {
    log_info "开始初始化 elasticsearch 镜像相关配置"
    docker cp $CONFIG_CONF_PATH/java/elasticsearch/config/elasticsearch.sh elasticsearch:/usr/share/elasticsearch/elasticsearch.sh
    docker exec elasticsearch /bin/bash -c "chmod -R 755 /usr/share/elasticsearch/elasticsearch.sh"
    docker exec elasticsearch /bin/bash -c "/usr/share/elasticsearch/elasticsearch.sh"
    log_info "初始化完成 elasticsearch 镜像相关配置"
}

function startAnalysis() {
    log_info "启动质检 spring 服务镜像"
    docker run -itd --name analysis --network host \
    -v $CONFIG_CONF_PATHE/java/config:/var/java/config \
    -v $CONFIG_CONF_PATH/java/fs:/var/java/fs \
    -v $CONFIG_CONF_PATH/java/tmp:/var/java/tmp \
    registry.cn-beijing.aliyuncs.com/tutorial/ai-analysis:$CONFIF_VERSION_SPRING
    log_info "正在启动质检 spring 服务中"
    sleep 90
    log_info "完成质检 spring 服务"
}

function startAnalysisHostMode() {
    log_info "启动质检 spring 服务镜像"
    docker run -itd --name analysis \
    -v $CONFIG_CONF_PATH/java/config:/var/java/config \
    -v $CONFIG_CONF_PATH/java/fs:/var/java/fs \
    -v $CONFIG_CONF_PATH/java/tmp:/var/java/tmp \
    registry.cn-beijing.aliyuncs.com/tutorial/ai-analysis:$CONFIF_VERSION_SPRING
    log_info "正在启动质检 spring 服务中"
    log_info "正在执行：docker run -itd --name analysis \
    -v $CONFIG_CONF_PATH/java/config:/var/java/config \
    -v $CONFIG_CONF_PATH/java/fs:/var/java/fs \
    -v $CONFIG_CONF_PATH/java/tmp:/var/java/tmp \
    registry.cn-beijing.aliyuncs.com/tutorial/ai-analysis:$CONFIF_VERSION_SPRING"
    sleep 90
    log_info "完成质检 spring 服务"
}

main() {
	DEPLOY_METHOD=$1
	case ${DEPLOY_METHOD} in
	  initPathAndConf)
		  initPathAndConf
		  ;;
	  startElasticsearch)
		  startElasticsearch
		  ;;
	  startElasticsearchHostMode)
		  startElasticsearchHostMode
		  ;;
	  confElasticsearch)
		  confElasticsearch
		  ;;
	  startAnalysis)
		  startAnalysis
		  ;;
	  startAnalysisHostMode)
		  startAnalysisHostMode
		  ;;
	esac
}

main "$1"
exit