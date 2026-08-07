/*86723*/
ALTER TABLE `aicall_manual_policy` ADD COLUMN `type` TINYINT(2) unsigned NOT NULL DEFAULT 0 COMMENT '策略类型 0:按变量转技能组 1:转技能组 2:按变量转坐席';
/*87903*/
UPDATE `outcall_task` SET statistics_completed = 0;
ALTER TABLE `outcall_task` ADD COLUMN `contact_info` varchar(1000) NOT NULL DEFAULT '' COMMENT '接通数、已联系总数、已联系接通数、各状态数';
/*87904*/
CREATE TABLE IF NOT EXISTS `apicb_record` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `eid` int(11) NOT NULL COMMENT '企业id',
  `task_id` int(11) NOT NULL COMMENT '任务id',
  `calllog_id` int(11) NOT NULL COMMENT 'calllog表id',
  `cc_number` varchar(100) NOT NULL DEFAULT '' COMMENT '通话唯一标识',
  `url` varchar(100) NOT NULL DEFAULT '' COMMENT '通话记录回调地址',
  `reqest_body` text NOT NULL COMMENT '请求内容',
  `response_body` text NOT NULL COMMENT '返回内容',
  `status` tinyint(10) unsigned NOT NULL DEFAULT '0' COMMENT '回调成功标志位',
  `request_count` tinyint(10) unsigned NOT NULL DEFAULT '0' COMMENT '回调次数',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*87925*/
CREATE TABLE IF NOT EXISTS `aicall_question_group`(
    `id`               int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `eid`              int(10)          NOT NULL            COMMENT '企业唯一ID',
    `script_id`        int(10)          NOT NULL DEFAULT 0  COMMENT '话术ID',
    `title`            varchar(100)     NOT NULL DEFAULT '' COMMENT '分组名称',
    `create_time`      int(10)          NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '问题分组';

ALTER TABLE `question` ADD COLUMN `question_group_id` int(10)    NOT NULL DEFAULT 0 COMMENT '问题分组id' AFTER `cluster_id`;

ALTER TABLE `question` ADD COLUMN `question_order`    tinyint(3) NOT NULL DEFAULT 0 COMMENT '问题排序' AFTER `question_group_id`;

ALTER TABLE `aicall_calllog_extension`
 ADD COLUMN
 `manual_incoming` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '转人工发起时间',
 ADD COLUMN
 `manual_confirm` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '转人工接听时间',
 ADD COLUMN
 `manual_disconnect` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '转人工挂断时间',
 ADD COLUMN
 `ring_duration` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'AI振铃时长';

ALTER TABLE `outcall_task` ADD COLUMN `predictive_config` varchar(500) NOT NULL DEFAULT '' COMMENT '预测式外呼配置字段：0. mode:模式（1为坐席空闲时外呼，2为预测式外呼且同时包含后五个字段 3坐席自主外呼 4弹屏后外呼 5转人工优先）1. answer_rate：接通率，0-1，1位小数。2. manual_success_rate：转人工率(转人工数/外呼数量)，0-1，1位小数。3. incoming_time：进线时长，单位秒4. manual_time：人工通话时间，单位秒。5. call_speed:外呼速率，默认1，大于0小于10，一位小数,6.delayed_time 延时,7.manual_answer_rate 转人工成功率(转人工接通数/转人工接数)，0-1，1位小数';
/*88267*/
CREATE TABLE IF NOT EXISTS `aicall_task_dispatcher_record` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业唯一ID ',
  `des_eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '将被分发到的企业id',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术id',
  `phone` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '手机号',
  `clue_no` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '线索别名',
  `var_values` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '变量值',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  PRIMARY KEY (`id`),
  KEY `index_phone` (`des_eid`,`phone`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='多企业任务分发记录表';

CREATE TABLE `aicall_calllog_monitor` (
    `id`           int(10)      UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
    `eid`          int(10)               NOT NULL DEFAULT '0'    COMMENT '企业唯一ID ',
    `task_id`      int(10)               NOT NULL DEFAULT '0'    COMMENT '任务ID',
    `task_name`    varchar(100)          NOT NULL DEFAULT ''     COMMENT '任务名称',
    `script_id`    int(10)               NOT NULL DEFAULT '0'    COMMENT '话术ID',
    `script_name`  varchar(100)          NOT NULL DEFAULT ''     COMMENT '话术名称',
    `clue_id`      int(10)               NOT NULL DEFAULT '0'    COMMENT '线索表ID',
    `calllog_id`   int(10)               NOT NULL DEFAULT '0'    COMMENT '通话记录id',
    `phone`        varchar(100)          NOT NULL DEFAULT ''     COMMENT '电话号码',
    `call_time`    int(10)               NOT NULL DEFAULT '0'    COMMENT '电话拨打时间',
    `current_num`  tinyint(2)            NOT NULL DEFAULT '1'    COMMENT '当前正在监控的人数',
    `status`       tinyint(2)            NOT NULL DEFAULT '1'    COMMENT '1，表示正在监控；2，表示监控后又关闭监控;',
    `create_time`  int(10)               NOT NULL,
    KEY `index_calllog_status` (`calllog_id`, `status`) USING BTREE,
    KEY `index_script_phone` (`script_id`, `phone`) USING BTREE,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='通话监控历史';
/*88268*/
ALTER TABLE `calllog` DROP INDEX `index_clue`;
ALTER TABLE `calllog` DROP INDEX `index_create_time`;

ALTER TABLE `calllog` ADD INDEX `index_callee_phone` (`callee_phone`) USING BTREE;
ALTER TABLE `calllog` ADD INDEX `index_create_time` (`create_time`,`enterprise_uid`) USING BTREE COMMENT '时间索引';
ALTER TABLE `calllog` ADD INDEX `index_task_id` (`task_id`,`create_time`) USING BTREE COMMENT '任务索引';
ALTER TABLE `calllog` ADD INDEX `index_script_id` (`script_id`,`create_time`) USING BTREE COMMENT '话术索引';

ALTER TABLE `outcall_task` DROP INDEX `start_time`;
ALTER TABLE `outcall_task` DROP INDEX `complete_time`;
ALTER TABLE `outcall_task` DROP INDEX `enterprise_uid`;
ALTER TABLE `outcall_task` DROP INDEX `index_edu`;

ALTER TABLE `outcall_task` ADD INDEX `index_name`  (`name`);
ALTER TABLE `outcall_task` ADD INDEX `index_uuid` (`uuid`);
ALTER TABLE `outcall_task` ADD INDEX `index_create_time` (`create_time`,`enterprise_uid`) USING BTREE;
ALTER TABLE `outcall_task` ADD INDEX `index_start_time` (`start_time`,`complete_time`,`enterprise_uid`) USING BTREE;
ALTER TABLE `outcall_task` ADD INDEX `index_enterprise_uid` (`enterprise_uid`, `task_status`) USING BTREE;
ALTER TABLE `outcall_task` ADD INDEX `index_department_id` (`department_id`, `user_id`) USING BTREE;

ALTER TABLE `aicall_outcall_clue_import_failed_history` ADD INDEX `index_phone` (`phone`);
ALTER TABLE `aicall_outcall_clue_import_failed_history` ADD INDEX `index_alias` (`alias`);
/*88269*/
ALTER TABLE `aicall_role` ADD COLUMN `data_type` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '查看数据类型 0 企业数据 1 部门数据 2 个人数据';

CREATE TABLE IF NOT EXISTS `aicall_phone_call_count_statistic` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键，任务编号',
  `enterprise_uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业唯一ID ',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务id',
  `clue_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '线索id',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术ID',
  `calllog_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '通话记录id',
  `call_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '外呼的次数',
  `callee_phone` varchar(100) NOT NULL DEFAULT '' COMMENT '手机号',
  `call_result` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '通话结果  1: 接通后挂断，2: 通话成功（只要有交互则算通话成功,  3:未接通，4:呼叫异常',
  `duration` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '通话时长',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间（时间 秒）',
  `call_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '呼叫时间（时间 秒）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_calllog_id` (`calllog_id`) USING BTREE COMMENT '通话记录id唯一',
  KEY `index_callee_phone` (`callee_phone`) USING BTREE COMMENT '手机号索引',
  KEY `index_create_time` (`enterprise_uid`,`create_time`) USING BTREE COMMENT '外呼轮次和状态索引'
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT='通话记录众安外呼轮次统计表';

CREATE TABLE IF NOT EXISTS `aicall_script_field_relation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '真实的eid',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '真实的话术id',
  `script_no` varchar(255)  NOT NULL DEFAULT '' COMMENT '客户场景编码',
  `var_keys_fields` varchar(1024) NOT NULL DEFAULT '' COMMENT '客户场景人物画像var_keys变量映射',
  `remark` varchar(1024) NOT NULL DEFAULT '' COMMENT '备注',
  `status` tinyint(2) NOT NULL DEFAULT '0' COMMENT '是否启动 0:不启用 1:启用',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_script_no` (`script_no`) USING BTREE,
  KEY `index_eid` (`eid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT='话术资源映射表';
/*88270*/
CREATE TABLE IF NOT EXISTS `aicall_script_analysis_classify` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业ID',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术ID',
  `script_node_name` varchar(200) NOT NULL DEFAULT '' COMMENT '节点名称',
  `script_node_id` varchar(200) NOT NULL DEFAULT '' COMMENT '节点id',
  `call_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '外呼的次数',
  `hangup_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '挂断节点数',
  `sentiment_positive_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积极数量',
  `sentiment_negative_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '消极数量',
  `sentiment_neutral_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '中性数量',
  `sentiment_change_positive_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积极变化数量',
  `sentiment_change_negative_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '消极变化数量',
  `sentiment_change_neutral_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '中性变化数量',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间（时间 秒）',
  `date_str` varchar(10) DEFAULT '' COMMENT '例如 20181224 方便查看',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_eid_script_time_node_count` (`eid`,`script_id`,`create_time`,`script_node_id`,`call_count`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT='话术分析冗余表';

/*#aicall_auth_action#aicall_auth_rule#aicall_auth_access#aicall_auth_rule_action#aicall_config#*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
    (0, 'manual_policy_number_controller', 1, 1, '转人工策略支持坐席', 2);

UPDATE `aicall_auth_action` SET `is_log` = 0, `model` = '' WHERE `id` = 232;
INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (312, 1, '', '/aicall/enterprise/setEnterpriseWechatConfig', '', '企业微信设置', 1, '企业微信设置', 'module_api');

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (11002, 312);
/*88271*/
CREATE TABLE IF NOT EXISTS `aicall_global_blacklist_sync` (
    `id`           int(10)      UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
    `eid`          int(10)               NOT NULL DEFAULT '0'    COMMENT '该条黑名单的来源企业ID ',
    `pid`          varchar(100)          NOT NULL DEFAULT ''     COMMENT '同一批次的企业',
    `mobile`        varchar(100)          NOT NULL DEFAULT ''     COMMENT '电话号码',
    `status`       tinyint(2)            NOT NULL DEFAULT '1'    COMMENT '0.待导入;1.导入完成;2.待删除;3.已删除;',
    `create_time`  int(10)               NOT NULL DEFAULT '0'    COMMENT '创建时间戳',
    UNIQUE KEY `index_pid_mobile` (`pid`, `mobile`) USING BTREE,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='多企业黑名单同步表';
/*88272*/
CREATE TABLE IF NOT EXISTS `aicall_holiday_mark` (
    `id`           int(10)      UNSIGNED NOT NULL AUTO_INCREMENT            COMMENT '主键',
    `year`         int(4)                NOT NULL DEFAULT '0'               COMMENT '标记的年份，格式为：2022',
    `month`        tinyint(2)            NOT NULL DEFAULT '1'               COMMENT '标记的月份，格式为：1',
    `day`          tinyint(2)            NOT NULL DEFAULT '1'               COMMENT '标记的日期，格式为：1',
    `type`         tinyint(2)            NOT NULL DEFAULT '1'               COMMENT '1为工作日，0为休息日',
    `create_time`  timestamp             NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
    UNIQUE KEY `index_year_month_day` (`year`, `month`, `day`) USING BTREE,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='节假日标记表';

ALTER TABLE `outcall_task` ADD COLUMN `task_calendar_status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '日历开关,以企业开关为准';

CREATE TABLE IF NOT EXISTS `aicall_calllog_subsidiary` (
  `calllog_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'calllog id',
  `update_status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '1:新架构cm通话记录更新成功',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`calllog_id`),
  KEY `index_update_status` (`update_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='企业通话日志扩展表';
/*89456*/
ALTER TABLE `outcall_task` ADD COLUMN `residue_recall_count` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '剩余重呼次数';

ALTER TABLE `aicall_calllog_continuous_sync`
    ADD COLUMN `manual_incoming`   int(10)     unsigned NOT NULL DEFAULT '0' COMMENT '转人工发起时间',
    ADD COLUMN `manual_confirm`    int(10)     unsigned NOT NULL DEFAULT '0' COMMENT '转人工接听时间',
    ADD COLUMN `manual_disconnect` int(10)     unsigned NOT NULL DEFAULT '0' COMMENT '转人工挂断时间',
    ADD COLUMN `ring_duration`     smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'AI振铃时长',
    ADD COLUMN `hangup_type`       tinyint(2)  unsigned NOT NULL DEFAULT '1' COMMENT '1:系统挂断 2:客户挂断';

ALTER TABLE `aicall_phone_call_count_statistic` 
    DROP COLUMN `call_time`,
    ADD COLUMN `intention_type` tinyint(3) unsigned NOT NULL DEFAULT '0';

CREATE TABLE IF NOT EXISTS `aicall_distribute_rule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业唯一ID ',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '规则名称',
  `rule` text COMMENT '规则内容',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_unique_eid` (`eid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COMMENT='分发规则表';

INSERT INTO `aicall_config` (`key`, `value`, `status`, `describe`, `type`) VALUES ('distribute_limit', '99', '1', '单号码分发数量上限', '2');

ALTER TABLE `aicall_task_dispatcher_record` ADD INDEX `index_create_time` (`create_time`) USING BTREE;

CREATE TABLE IF NOT EXISTS `aicall_task_dispatcher_record_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业唯一ID ',
  `des_eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '将被分发到的企业id',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术id',
  `phone` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '手机号',
  `clue_no` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '线索别名',
  `var_values` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '变量值',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  PRIMARY KEY (`id`),
  KEY `index_phone` (`des_eid`,`phone`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='多企业任务分发历史记录表';
/*89457*/
ALTER TABLE `aicall_script_analysis` DROP INDEX `index_eid_script_id_node_id`;
ALTER TABLE `aicall_script_analysis` ADD KEY `index_script_time_node_task_count` (`eid`,`script_id`,`script_node_id`,`create_time`,`task_id`,`call_count`) USING BTREE;

INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
    (0, 'batch_tasks_controller', '1', '1', '批量启动开关', '2');
UPDATE `aicall_config` SET `value` = '30' WHERE `key` = 'max_task_run_count_limit';

ALTER TABLE `apicb_record` ADD INDEX `index_calllog_id` (`calllog_id`);
ALTER TABLE `apicb_record` ADD INDEX `index_task_id` (`task_id`,`status`);
ALTER TABLE `apicb_record` ADD INDEX `index_cc_number` (`cc_number`);
ALTER TABLE `apicb_record` ADD INDEX `index_create_time` (`create_time`, `eid`);

ALTER TABLE `account` ADD INDEX index_enterprise_uid (`enterprise_uid`, `from_user`);
/*89458*/
ALTER TABLE aicall_script_field_relation MODIFY COLUMN `var_keys_fields` varchar(5000) NOT NULL DEFAULT '' COMMENT '客户场景人物画像var_keys变量映射';

ALTER TABLE aicall_sms_send_history ADD COLUMN `sms_template_id` int(10) NOT NULL COMMENT 'sms_template表主键id';
ALTER TABLE aicall_sms_send_history ADD COLUMN `batch_id` int(10) NOT NULL COMMENT 'aicall_sms_manual_send_batch表主键id';
ALTER TABLE aicall_sms_send_history ADD COLUMN `clue_id` int(10) NOT NULL COMMENT 'outcall_clue表主键id';

ALTER TABLE aicall_enterprise_sms ADD COLUMN `send_cycle` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送周期';
ALTER TABLE aicall_enterprise_sms ADD COLUMN `send_times` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '发送次数';

ALTER TABLE sms_template ADD COLUMN `send_cycle` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送周期';
ALTER TABLE sms_template ADD COLUMN `send_times` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '发送次数';

UPDATE aicall_push_sms_template SET `sms_content` = '您好！您有%u位%s类意向客户产生，请及时查看！任务名称：%s，话术名称：%s，详情请登录%s查看' WHERE id = 1;
UPDATE aicall_push_sms_template SET `sms_content` = '您好！您有%u位%s类意向客户产生，请及时查看！任务名称：%s，话术名称：%s，客户号码：%s，详情请登录%s查看，也可直接%s' WHERE id = 2;

ALTER TABLE aicall_calllog_horary_statistics ADD COLUMN `manual_missed` int(10) unsigned DEFAULT '0' COMMENT '转人工坐席未接听';
ALTER TABLE aicall_calllog_horary_statistics ADD COLUMN `manual_denied` int(10) unsigned DEFAULT '0' COMMENT '转人工坐席拒接';

ALTER TABLE aicall_calllog_horary_statistics ADD COLUMN `manual_call_duration` int(10) unsigned DEFAULT '0' COMMENT '坐席通话总时长';
ALTER TABLE aicall_calllog_horary_statistics ADD COLUMN `manual_call_minutes` int(10) unsigned DEFAULT '0' COMMENT '坐席通话总分钟数';
/*90334*/
UPDATE aicall_push_sms_template SET `sms_content` = '您好！您有%u位%s类意向客户产生，请及时查看！任务名称：%s，话术名称：%s，客户号码：%s，详情请登录%s查看。%s' WHERE id = 2;
ALTER TABLE aicall_calllog_horary_statistics DROP KEY uk_date_eid;
ALTER TABLE aicall_calllog_horary_statistics ADD UNIQUE KEY `uk_date_eid` (`horary_date`,`enterprise_uid`,`task_id`, `script_id`) USING BTREE COMMENT '用户日期-任务-话术唯一索引';
/*91230*/
