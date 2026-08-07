/*1*/
-- ----------------------------
-- Table structure for aicall_sync
-- ----------------------------
DROP TABLE IF EXISTS `aicall_sync`;
CREATE TABLE `aicall_sync` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `primary_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '模块表主键id',
  `eid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '企业id',
  `sync_time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '操作时间',
  `module` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT '操作模型1:task;2:outcall_customer',
  `type` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT '1:create;2:modify;3:delete;',
  PRIMARY KEY (`id`),
  KEY `index_eid` (`eid`),
  KEY `index_sync_time` (`sync_time`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='同步表';

-- ----------------------------
-- Table structure for aicall_api_user
-- ----------------------------
DROP TABLE IF EXISTS `aicall_api_user`;
CREATE TABLE `aicall_api_user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) NOT NULL DEFAULT 0 COMMENT '企业ID',
  `appid` varchar(100) NOT NULL DEFAULT '' COMMENT 'appid',
  `secret` varchar(100) NOT NULL DEFAULT '' COMMENT '密钥',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '是否可用1可用0不可用',
  `create_time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `index_appid` (`appid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='api用户表';

-- ----------------------------
-- Table structure for aicall_access_token
-- ----------------------------
DROP TABLE IF EXISTS `aicall_access_token`;
CREATE TABLE `aicall_access_token` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(20) NOT NULL DEFAULT '' COMMENT '来源ip',
  `api_uid` int(10) NOT NULL DEFAULT 0 COMMENT 'uid',
  `access_token` varchar(100) NOT NULL DEFAULT '' COMMENT '令牌',
  `create_time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '创建时间',
  `expiry_time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '过期时间',
  PRIMARY KEY (`id`),
  KEY `index_api_uid` (`api_uid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='api访问令牌表';

-- ----------------------------
-- Table structure for aicall_api_log
-- ----------------------------
DROP TABLE IF EXISTS `aicall_api_log`;
CREATE TABLE `aicall_api_log` (
  `api` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) NOT NULL DEFAULT 0 COMMENT '企业id',
  `api_uid` int(10) DEFAULT NULL COMMENT 'api用户',
  `duration` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '花费时间',
  `api_name` varchar(255) DEFAULT NULL COMMENT '接口名称',
  `time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '请求时间',
  `ip` varchar(20) NOT NULL DEFAULT '' COMMENT 'ip',
  `status` int(10) NOT NULL DEFAULT 0 COMMENT 'api返回结果',
  PRIMARY KEY (`api`),
  KEY `index_eid` (`eid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='API 日志表';

/*#aicall_user#aicall_config#aicall_auth_rule#*/
ALTER TABLE `aicall_user` DROP INDEX `index_username`;
ALTER TABLE `aicall_user` ADD UNIQUE KEY `index_unique_username` (`username`) USING BTREE COMMENT '用户名称唯一索引';

ALTER TABLE `aicall_config` DROP INDEX `index_ep_id`;
ALTER TABLE `aicall_config` DROP INDEX `index_key`;
ALTER TABLE `aicall_config` ADD UNIQUE KEY `index_unique_eid_key` (`eid`,`key`) USING BTREE COMMENT '企业键值唯一索引';

ALTER TABLE `aicall_auth_rule` DROP INDEX `index_module`;
ALTER TABLE `aicall_auth_rule` DROP INDEX `name`;
ALTER TABLE `aicall_auth_rule` ADD UNIQUE KEY `index_unique_name` (`name`) USING BTREE COMMENT '权限规则名称唯一索引';
ALTER TABLE `aicall_auth_rule` ADD KEY `index_auth_module` (`app`,`status`,`type`) USING BTREE COMMENT '权限索引';

-- ----------------------------
-- Table structure for aicall_oc_callback
-- ----------------------------
DROP TABLE IF EXISTS `aicall_oc_callback`;
CREATE TABLE `aicall_oc_callback` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(20) NOT NULL DEFAULT '' COMMENT '请求ip',
  `api` varchar(128)  NOT NULL DEFAULT '' COMMENT '回调接口',
  `api_data` text COMMENT '回调数据',
  `api_result` varchar(255)  NOT NULL DEFAULT '' COMMENT '回调结果',
`time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '请求时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='OC服务器回调数据表';
/*2*/
-- ----------------------------
-- OC step1--
ALTER TABLE `outcall_task` ADD `task_pause_start_time` varchar(20) NOT NULL DEFAULT '';
ALTER TABLE `outcall_task` ADD `task_pause_end_time` varchar(20) NOT NULL DEFAULT '';
ALTER TABLE `outcall_task` ADD `task_scheduled_start_time` int(10) NOT NULL DEFAULT 0;
ALTER TABLE `outcall_task` ADD `uuid` varchar(200) NOT NULL DEFAULT '';
ALTER TABLE `outcall_task` ADD `bound_switch_number` varchar(200) NOT NULL  DEFAULT '';


ALTER TABLE `calllog` ADD `answer_time` int(10) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `calllog` ADD `hangup_time` int(10) unsigned NOT NULL DEFAULT 0;

-- ALTER TABLE `outcall_clue` ADD UNIQUE `clue_phone` (`phone`,`task_id`);

ALTER TABLE `script` ADD `tts_flag` int(10) NOT NULL DEFAULT 0;

ALTER TABLE `calllog` ADD `call_record_url` varchar(400) NOT NULL DEFAULT '';

-- ALTER TABLE failed_outcall ADD INDEX index_clue(clue_id);

-- ALTER TABLE failed_outcall ADD INDEX index_recall(task_id, recall_status);

-- ALTER TABLE ai.calllog ADD INDEX index_clue(task_id, clue_id);
-- OC step2--
-- ALTER TABLE script ADD INDEX uk_eid_name(enterprise_uid,name);

-- ALTER TABLE sms_template ADD INDEX uk_eid_name(enterprise_uid,name);

-- ALTER TABLE custom_field ADD INDEX uk_eid_name(enterprise_uid,name);

-- ALTER TABLE label_group ADD INDEX uk_eid_name(enterprise_uid,name);

-- ALTER TABLE cluster ADD INDEX uk_eid_name(enterprise_uid,name);

-- ALTER TABLE question ADD INDEX uk_eid_question (enterprise_uid,standard_question);

ALTER TABLE `calllog` add `match_global_keyword` varchar(500) NOT NULL DEFAULT '';

-- ALTER TABLE outcall_clue ADD INDEX index_status_task(task_id, finished);

ALTER TABLE `question` DROP column `answer_record_addr`;

ALTER TABLE `question` DROP column `duration`;

ALTER TABLE `audio` ADD `audio_src` varchar(200) NOT NULL DEFAULT '';

UPDATE `audio` SET `audio_src` = CONCAT('robot/', substring_index(`src`, '/mnt/fs/', -1));

ALTER TABLE `audio` DROP column `src`;

ALTER TABLE `audio` DROP column `relative_src`;

CREATE TABLE IF NOT EXISTS `failed_callback`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `enterprise_uid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `callback_url` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '回调URL',
  `load_data` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '回调负载数据',
  `reason` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '最新回调失败原因',
  `callback_times` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '重复回调失败次数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 0 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;
-- ----------------------------
/*51434*/
-- ----------------------------
-- Table structure for aicall_text_tts
-- ----------------------------
DROP TABLE IF EXISTS `aicall_text_tts`;
CREATE TABLE `aicall_text_tts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `text` varchar(400) NOT NULL COMMENT '文本',
  `text_md5` varchar(32) NOT NULL COMMENT '文本md5',
  `tts_duration` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'tts时长',
  `tts_src` varchar(500) NOT NULL DEFAULT '' COMMENT 'tts语音路径',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_unique_text_md5` (`text_md5`) USING BTREE COMMENT '文本唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='文本转tts表';

INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
  (0,'upload_filename_length','50',1,'上传文件名长度限制',2),
  (0,'script_name_length_limit','20',1,'话术名称长度限制',2),
  (0,'script_catch_length_limit','60',1,'未匹配到聚类、静音超时、转人工坐席设置等 catch 内的话术文本长度',2),
  (0,'script_session_count_limit','20',1,'会话轮数限制',2),
  (0,'script_node_text_length_limit','200',1,'话术节点文本长度限制',2),
  (0,'script_globle_keyword_count_limit','10',1,'全语境关键字个数限制',2),
  (0,'script_intention_keyword_count_limit','12',1,'话术意向性关键字个数限制',2);

ALTER TABLE `question` ADD `tts_id` int(10) unsigned NOT NULL DEFAULT 0 AFTER `audio_id`;
ALTER TABLE `question` ADD `jump_tts_id` int(10) unsigned NOT NULL DEFAULT 0 AFTER `jump_audio_id`;

ALTER TABLE `enterprise_info` MODIFY COLUMN `name` varchar(100) NOT NULL DEFAULT '';
ALTER TABLE `enterprise_info` MODIFY COLUMN `switch_number` varchar(1500) NOT NULL DEFAULT '';

ALTER TABLE `outcall_clue` DROP INDEX `index_status_task`;
ALTER TABLE `outcall_clue` DROP INDEX `clue_phone`;
ALTER TABLE `outcall_clue` ADD UNIQUE KEY `index_unique_task_id_phone` (`task_id`, `phone`) USING BTREE COMMENT '线索任务手机号唯一索引';

ALTER TABLE `calllog` MODIFY COLUMN label varchar(300) NOT NULL DEFAULT '';
ALTER TABLE `outcall_task` MODIFY COLUMN `name` varchar(120) NOT NULL DEFAULT '';
/*51435*/
ALTER table `sms_template` MODIFY COLUMN content varchar(400) NOT NULL DEFAULT '';

Alter table calllog add transfer_number varchar(20) NOT NULL DEFAULT '';

Alter table calllog add transfer_duration smallint(5) unsigned NOT NULL DEFAULT '0';

Alter table `failed_callback` add cc_number varchar(100) NOT NULL DEFAULT '';

Alter table `failed_callback` add calllog_id int(10) NOT NULL DEFAULT '0';

Alter table `failed_callback` add recent_time int(10) NOT NULL DEFAULT '0';

Alter table `outcall_clue` add alias varchar(50) NOT NULL DEFAULT '';
/*51436*/
-- ----------------------------
-- Table structure for aicall_global_blacklist
-- ----------------------------
DROP TABLE IF EXISTS `aicall_global_blacklist`;
CREATE TABLE `aicall_global_blacklist` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
  `name` varchar(10) NOT NULL DEFAULT '' COMMENT '机主名称',
  `city` varchar(20) NOT NULL DEFAULT '' COMMENT '城市',
  `create_time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `index_mobile` (`mobile`) USING BTREE COMMENT '手机索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='全网黑名单手机号表';

-- ----------------------------
-- Table structure for aicall_mobile_info
-- ----------------------------
DROP TABLE IF EXISTS `aicall_mobile_info`;
CREATE TABLE `aicall_mobile_info` (
  `mobile_code` varchar(10) NOT NULL COMMENT '手机号代码',
  `area_code` varchar(10) NOT NULL DEFAULT '' COMMENT '区域区号',
  `province` varchar(20) NOT NULL DEFAULT '' COMMENT '省份',
  `city` varchar(20) NOT NULL DEFAULT '' COMMENT '城市',
  `manufacturer` varchar(10) NOT NULL DEFAULT '' COMMENT '厂商',
  PRIMARY KEY (`mobile_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='手机号信息表';

ALTER TABLE `outcall_clue` ADD `area_code` varchar(10) NOT NULL DEFAULT '';
ALTER TABLE `script` MODIFY COLUMN `name` varchar(50) NOT NULL DEFAULT '';
-- ALTER TABLE `outcall_clue` ADD `delete_flag` tinyint(2) unsigned NOT NULL DEFAULT 0;
-- ALTER TABLE `outcall_task` ADD `delete_flag` tinyint(2) unsigned NOT NULL DEFAULT 0;
/*52708*/
ALTER TABLE `calllog` ADD INDEX `index_create_time` (`create_time`) USING BTREE COMMENT '时间索引';
ALTER TABLE `calllog` ADD INDEX `index_cc_number` (`cc_number`) USING BTREE;
ALTER TABLE `outcall_clue` ADD INDEX `index_task_id_finished` (`task_id`,`finished`) USING BTREE;

ALTER TABLE `outcall_clue` ADD INDEX `index_create_time` (`create_time`) USING BTREE;
ALTER TABLE `calllog` ADD INDEX `index_enterprise_uid` (`enterprise_uid`) USING BTREE;
ALTER TABLE `calllog` ADD INDEX `index_intention_type` (`intention_type`, `task_id`) USING BTREE;
ALTER TABLE `calllog` ADD INDEX `index_clue_id` (`clue_id`) USING BTREE;
/*53562*/
ALTER TABLE `aicall_global_blacklist` DROP INDEX `index_mobile`;
ALTER TABLE `aicall_global_blacklist` ADD UNIQUE KEY `index_unique_mobile` (`mobile`) USING BTREE COMMENT '手机号唯一索引';
/*53582*/
DELIMITER $$
DROP PROCEDURE IF EXISTS `procedure_user_role_add` $$
CREATE PROCEDURE `procedure_user_role_add`(in username varchar(200), in password varchar(200), in nickname varchar(200), out user_id int, out role_id int)
BEGIN
  INSERT INTO `aicall_role` VALUES (NULl, 0, 1, 0, 0, 0, nickname, '', 0) ;
  INSERT INTO `aicall_user` VALUES (NULL, username, password, 0, nickname, '', '', 0, 1, 0, '', '', 0, 0, '');
  SELECT max(id) from `aicall_user` into `user_id`;
  SELECT max(id) from `aicall_role` into `role_id`;
  INSERT INTO `aicall_user_role` (`user_id`, `role_id`) (SELECT `user_id`,`role_id`);
  SELECT `user_id`, `role_id`;
END $$
call procedure_user_role_add('yimi_123456', 'e131fe5f76afa7f7fde1d075731085ba', '运维管理员', @user_id, @role_id) $$
DELIMITER ;

ALTER TABLE `enterprise_info` ADD `account_status` int(10) NOT NULL DEFAULT '1';
ALTER TABLE `failed_callback` ADD `extrl_config_code` int(10) NOT NULL DEFAULT 0 COMMENT '获取record_url:1';
DROP TABLE IF EXISTS `failed_outcall`;
DROP TABLE IF EXISTS `aicall_oc_callback`;
DROP TABLE IF EXISTS `outcall_daily_statistics`;
DROP TABLE IF EXISTS `ai_speech_reco_log`;

-- ----------------------------
-- Table structure for aicall_tts_version
-- ----------------------------
DROP TABLE IF EXISTS `aicall_tts_version`;
CREATE TABLE `aicall_tts_version` (
  `tts_version_code` int(10) unsigned DEFAULT 0 COMMENT 'tts版本代码　16进制',
  `tts_version_desc` varchar(20) NOT NULL DEFAULT '' COMMENT 'tts版本描述',
  PRIMARY KEY (`tts_version_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='tts版本表';

-- ----------------------------
-- Table structure for aicall_text_tts_version
-- ----------------------------
DROP TABLE IF EXISTS `aicall_text_tts_version`;
CREATE TABLE `aicall_text_tts_version` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `text_tts_id` int(10) unsigned NOT NULL COMMENT 'tts文本id',
  `tts_version_code` int(10) unsigned NOT NULL COMMENT 'tts版本代码',
  `tts_src` varchar(500) NOT NULL DEFAULT '' COMMENT 'tts语音路径',
  `tts_duration` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'tts时长',
  `create_time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_unique_text_tts_id` (`text_tts_id`, `tts_version_code`) USING BTREE COMMENT 'tts合成唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='tts版本表';

INSERT INTO `aicall_tts_version`(`tts_version_code`,`tts_version_desc`) VALUES (0x0001, '女');
INSERT INTO `aicall_tts_version`(`tts_version_code`,`tts_version_desc`) VALUES (0x0002, '男');
INSERT INTO `aicall_text_tts_version`(`text_tts_id`,`tts_version_code`,`tts_src`,`tts_duration`,`create_time`) select id,0x0001,tts_src,tts_duration,unix_timestamp(now()) from `aicall_text_tts`;

ALTER TABLE `script` ADD `tts_version_code` int(10) NOT NULL DEFAULT 0 COMMENT 'tts版本 0x0001:女 0x0002男';
UPDATE `script` SET `tts_version_code` = 0x0001 WHERE `tts_flag` = 1;
ALTER TABLE `aicall_text_tts` DROP column `tts_src`;
ALTER TABLE `aicall_text_tts` DROP column `tts_duration`;
/*53937*/
ALTER TABLE `outcall_clue` DROP INDEX `index_unique_task_id_phone`;
ALTER TABLE `outcall_clue` ADD UNIQUE KEY `index_phone` (`phone`, `task_id`) USING BTREE COMMENT '线索任务手机号唯一索引';

source mysql/v_all_task_complete_today.sql;
ALTER TABLE `calllog` ADD `message_count` tinyint(4) NOT NULL DEFAULT '0' COMMENT '发送短信数量',ADD COLUMN `hangup_node_text` VARCHAR(500) NOT NULL DEFAULT '';

-- ----------------------------
-- Table structure for aicall_calllog_label
-- ----------------------------
DROP TABLE IF EXISTS `aicall_calllog_label`;
CREATE TABLE `aicall_calllog_label` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务ID',
  `calllog_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '通话记录ID',
  `label_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '标签组ID',
  `label` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '标签',
  `create_time` int(10) NOT NULL DEFAULT '0' COMMENT '插入时间',
  PRIMARY KEY (`id`),
  KEY `index_calllog_id` (`task_id`,`calllog_id`) USING BTREE,
  KEY `index_label` (`task_id`,`label_id`,`label`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='通话记录标签关联表';

-- ----------------------------
-- Table structure for aicall_calllog_horary_statistics
-- ----------------------------
DROP TABLE IF EXISTS `aicall_calllog_horary_statistics`;
CREATE TABLE `aicall_calllog_horary_statistics` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `enterprise_uid` int(10) unsigned DEFAULT '0' COMMENT '企业id',
  `task_id` int(10) unsigned DEFAULT '0' COMMENT '任务id',
  `script_id` int(10) unsigned DEFAULT '0' COMMENT '话术id',
  `horary_date` varchar(10)  DEFAULT '0' COMMENT '时间例如(20181224_08)',
  `total_call_duration` int(10) unsigned DEFAULT '0' COMMENT '通话总时长',
  `total_call_count` int(10) unsigned DEFAULT '0' COMMENT '通话总数量',
  `message_count` int(10) unsigned DEFAULT '0' COMMENT '短信发送数量',
  `manual_failed` int(10) unsigned DEFAULT '0' COMMENT '转接失败数量',
  `manual_success` int(10) unsigned DEFAULT '0' COMMENT '转接成功数量',
  `connected_call_count` int(10) unsigned DEFAULT '0' COMMENT '接通数量',
  `intention_a_count` int(10) unsigned DEFAULT '0' COMMENT '意向性a数量',
  `intention_b_count` int(10) unsigned DEFAULT '0' COMMENT '意向性b数量',
  `intention_c_count` int(10) unsigned DEFAULT '0' COMMENT '意向性c数量',
  `intention_d_count` int(10) unsigned DEFAULT '0' COMMENT '意向性d数量',
  `intention_e_count` int(10) unsigned DEFAULT '0' COMMENT '意向性e数量',
  `intention_f_count` int(10) unsigned DEFAULT '0' COMMENT '意向性f数量',
  `intention_g_count` int(10) unsigned DEFAULT '0' COMMENT '意向性g数量',
  `intention_h_count` int(10) unsigned DEFAULT '0' COMMENT '意向性h数量',
  `intention_i_count` int(10) unsigned DEFAULT '0' COMMENT '意向性i数量',
  `duration_0_10_count` int(10) unsigned DEFAULT '0' COMMENT '0-10秒通话数量数量',
  `duration_10_20_count` int(10) unsigned DEFAULT '0' COMMENT '10-20秒通话数量',
  `duration_20_30_count` int(10) unsigned DEFAULT '0' COMMENT '20-30秒通话数量',
  `duration_30_40_count` int(10) unsigned DEFAULT '0' COMMENT '30-40秒通话数量',
  `duration_40_50_count` int(10) unsigned DEFAULT '0' COMMENT '40-50秒通话数量',
  `duration_50_60_count` int(10) unsigned DEFAULT '0' COMMENT '50-60秒通话数量',
  `duration_60_70_count` int(10) unsigned DEFAULT '0' COMMENT '60-70秒通话数量',
  `duration_70_80_count` int(10) unsigned DEFAULT '0' COMMENT '70-80秒通话数量',
  `duration_80_90_count` int(10) unsigned DEFAULT '0' COMMENT '80-90秒通话数量',
  `duration_90_100_count` int(10) unsigned DEFAULT '0' COMMENT '90-100秒通话数量',
  `duration_100_110_count` int(10) unsigned DEFAULT '0' COMMENT '100-110秒通话数量',
  `duration_110_120_count` int(10) unsigned DEFAULT '0' COMMENT '110-120秒通话数量',
  `duration_other_count` int(10) unsigned DEFAULT '0' COMMENT '其他时间通话数量',
  `result_call_answered` int(10) unsigned DEFAULT '0' COMMENT '通话状态-接听',
  `result_call_answered_and_hangup` int(10) unsigned DEFAULT '0' COMMENT '通话状态-接听并挂机',
  `result_call_not_answered` int(10) unsigned DEFAULT '0' COMMENT '通话状态-未接听',
  `result_call_failed` int(10) unsigned DEFAULT '0' COMMENT '通话状态-外呼失败',
  `result_call_rejected` int(10) unsigned DEFAULT '0' COMMENT '通话状态-拒接',
  `result_call_number_not_find` int(10) unsigned DEFAULT '0' COMMENT '通话状态-空号',
  `result_call_shutdown` int(10) unsigned DEFAULT '0' COMMENT '通话状态-关机',
  `result_call_downtime` int(10) unsigned DEFAULT '0' COMMENT '通话状态-停机',
  `result_call_out_of_service` int(10) unsigned DEFAULT '0' COMMENT '通话状态-不在服务区',
  `result_call_busy_line` int(10) unsigned DEFAULT '0' COMMENT '通话状态-占线',
  `result_call_switch_number_arrears` int(10) unsigned DEFAULT '0' COMMENT '通话状态-总机关机',
  `is_end` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '统计是否完成，1未完成，2完成',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_date_eid` (`horary_date`,`enterprise_uid`,`task_id`) USING BTREE COMMENT '用户日期唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for aicall_ip_white_list
-- ----------------------------
DROP TABLE IF EXISTS `aicall_ip_white_list`;
CREATE TABLE `aicall_ip_white_list` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL COMMENT '所属企业id',
  `ip_address` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT 'ip地址',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_eid_ip` (`eid`,`ip_address`) USING BTREE COMMENT 'ip地址和企业id的唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='企业api ip白名单表';

-- ----------------------------
-- Table structure for aicall_mix_tts
-- ----------------------------
DROP TABLE IF EXISTS `aicall_mix_tts`;
CREATE TABLE `aicall_mix_tts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `enterprise_uid` int(10) unsigned NOT NULL COMMENT '所属企业id',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='聚类语音合成记录表';

-- ----------------------------
-- Table structure for aicall_mix_tts_order
-- ----------------------------
DROP TABLE IF EXISTS `aicall_mix_tts_order`;
CREATE TABLE `aicall_mix_tts_order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mix_tts_id` int(10) unsigned NOT NULL COMMENT '话术聚类语音合成表id',
  `audio_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'audio对应的id 或者 tts对应的id',
  `tts_text` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT 'tts文本内容',
  `type` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '类型 0 音频文件 1 需要现生成tts',
  `order_by` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '排序从0开始依次类推',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='聚类语音合成顺序记录表';

ALTER TABLE `question` ADD `mix_tts_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '混编tts编号';
ALTER TABLE `custom_field` ADD `rule` varchar(512) NOT NULL DEFAULT '' COMMENT '变量替换规则';

INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
	(0,'field_rule_count_limit','20',1,'变量规则数量上限',2),
	(0,'field_rule_length_limit','10',1,'变量规则10个字（不可输入特殊符号）',2),
	(0,'ip_white_list_count_limit','50',1,'ip白名单数量限制',2);
/*55607*/
ALTER TABLE `question` ADD `jump_mix_tts_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '跳转文本混编tts编号';
ALTER TABLE `enterprise_info` add `oc_ip` varchar(100) not null DEFAULT '' COMMENT 'default 值需跟OC匹配';
-- ----------------------------
-- Table structure for aicall_sms_send_history
-- ----------------------------
DROP TABLE IF EXISTS `aicall_sms_send_history`;
CREATE TABLE IF NOT EXISTS `aicall_sms_send_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL COMMENT '所属企业id',
  `sms_code` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '短信通道',
  `mobile` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '手机号',
  `msg` varchar(2000) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '短信文本',
  `status` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送状态',
  `result` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '发送结果',
  `send_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送时间',
  PRIMARY KEY (`id`),
  INDEX `idx_eid` (`eid`),
  INDEX `idx_mobile` (`mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci comment '短信发送历史表';

-- ----------------------------
-- Table structure for aicall_sms_gateway
-- ----------------------------
DROP TABLE IF EXISTS `aicall_sms_gateway`;
CREATE TABLE `aicall_sms_gateway` (
  `sms_code` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '短信网关配置唯一码',
  `name` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '短信配置名称',
  `sms_url` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '对应的短信api地址',
  PRIMARY KEY (`sms_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='短信网关类型配置';

INSERT INTO `aicall_sms_gateway` VALUES ('yimei', '亿美', 'shmtn.b2m.cn:80');
INSERT INTO `aicall_sms_gateway` VALUES ('zhutong', '助通', 'vip.zthysms.com/sendSms.do');
-- ----------------------------
-- Table structure for aicall_enterprise_sms
-- ----------------------------
DROP TABLE IF EXISTS `aicall_enterprise_sms`;
CREATE TABLE `aicall_enterprise_sms` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sms_code` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '短信对应的网关code',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业id',
  `status` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '状态 0 关闭 1 开启',
  `username` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '用户名',
  `password` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '密码',
  `signature` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '短信签名',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_eid` (`eid`) USING BTREE COMMENT '用户唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='企业短信配置表';

ALTER TABLE `aicall_mix_tts_order` ADD KEY `idx_mix_tts_id_order` (`mix_tts_id`,`order_by`) USING BTREE COMMENT 'mix_tts_id 和 order_by 字段联合索引';
/*#aicall_config#*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
	(0,'tts_text_length_limit','100',1,'TTS节点字数限制',2),
	(0,'tts_mix_count_limit','10',1,'混编节点上传个数限制',2);
/*56473*/
-- ----------------------------
-- Table structure for aicall_tts_version
-- ----------------------------
DROP TABLE IF EXISTS `aicall_tts_version`;
CREATE TABLE `aicall_tts_version` (
  `tts_version_code` int(10) unsigned DEFAULT 0 COMMENT 'tts版本代码　16进制',
  `tts_version_desc` varchar(20) NOT NULL DEFAULT '' COMMENT 'tts版本描述',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT '顺序',
  `api_version` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'API版本',
  PRIMARY KEY (`tts_version_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='tts版本表';

INSERT INTO `aicall_tts_version`(`tts_version_code`,`tts_version_desc`,`order`,`api_version`) VALUES (0x0001, '客服女声', 1, 1);
INSERT INTO `aicall_tts_version`(`tts_version_code`,`tts_version_desc`,`order`,`api_version`) VALUES (0x0002, '客服男声', 3, 1);
INSERT INTO `aicall_tts_version`(`tts_version_code`,`tts_version_desc`,`order`,`api_version`) VALUES (0x0003, '邻家女声', 2, 2);
/*56474*/
source mysql/v_all_task_today.sql;
ALTER TABLE `script` MODIFY COLUMN `name` varchar(200) NOT NULL DEFAULT '';
ALTER TABLE `calllog` MODIFY COLUMN `script_name` varchar(200) NOT NULL DEFAULT '';
ALTER TABLE `outcall_clue` MODIFY COLUMN `script_name` varchar(200) NOT NULL DEFAULT '';
ALTER TABLE `outcall_task` MODIFY COLUMN `script_name` varchar(200) NOT NULL DEFAULT '';
ALTER TABLE `query_question_script` MODIFY COLUMN `script_name` varchar(200) NOT NULL DEFAULT '';
/*57278*/
/*#aicall_config#question#*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
  (0,'role_count_limit','50',1,'角色个数限制',2),
  (0,'account_count_limit','50',1,'账户个数限制',2),
  (0,'role_title_length_limit','30',1,'角色名称长度限制',2),
  (0,'account_title_length_limit','30',1,'账户名称长度限制',2),
  (0,'role_remark_length_limit','200',1,'角色描述长度限制',2),
  (0,'outcall_server_host',	'172.17.214.17',	1,'外呼服务器host',	1),
  (0,'outcall_server_port',	'9009',1,	'外呼服务器端口'	,1),
  (0,'outcall_server_protocol',	'http',1,	'外呼服务器请求协议',1),
  (0,'web_miitbeian_url',	'http://beian.miit.gov.cn',1,	'网站备案号的链接地址',1);

ALTER TABLE `outcall_task` ADD COLUMN `auto_recall_status` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '自动重呼开关，0：关闭，1：开启';
ALTER TABLE `outcall_task` ADD COLUMN `auto_recall_scenes` varchar(100) NOT NULL DEFAULT '' COMMENT '自动重呼场景JSON，1：客户静默，2：通话成功，3：未接听，4：外呼失败，5：拒接，6：空号，7：关机，8：停机，9：不在服务区，10：占线，11：总机欠费';
ALTER TABLE `outcall_task` ADD COLUMN `auto_recall_interval` smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT '自动重呼间隔，可选值1-3600，单位秒';
ALTER TABLE `outcall_task` ADD COLUMN `auto_recall_max_times` tinyint(2) UNSIGNED NOT NULL DEFAULT 0 COMMENT '自动重呼次数上限，可选值1-10';
ALTER TABLE `outcall_task` ADD COLUMN `auto_recall_times` tinyint(2) UNSIGNED NOT NULL DEFAULT 0 COMMENT '已重呼次数';
ALTER TABLE `calllog` ADD COLUMN `buttons` varchar(50) NOT NULL DEFAULT '' COMMENT '按键，JSON';
ALTER TABLE `question` DROP COLUMN `jump_audio_name`;
ALTER TABLE `custom_field` DROP COLUMN `rule`;
ALTER TABLE `custom_field` ADD COLUMN `figure` varchar(100) NOT NULL DEFAULT '' COMMENT '数字读法 digit:数字读法 ordinal:电报读法';
ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `result_call_restriction` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '外呼限制' AFTER `result_call_switch_number_arrears`;
/*57415*/
ALTER TABLE `aicall_user` ADD  `update_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后编辑时间' AFTER `last_ip`;
ALTER TABLE `aicall_user` ADD  `order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '排序' AFTER `update_time`;

ALTER TABLE `aicall_role` ADD  `eid` int(10) NOT NULL DEFAULT 0 COMMENT '企业ID 0表示系统角色' AFTER `parent_id`;
ALTER TABLE `aicall_role` ADD INDEX `index_eid` (`eid`);

INSERT INTO `aicall_enterprise_sms` (`sms_code`, `eid`, `status`, `username`, `password`, `signature`, `create_time`)
VALUES
	('yimei', 0, 1, 'EUCP-EMY-SMS1-6EUGV', 'EBEA7F1987AABBE4', '易米云通', 1558582794);

INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
  (0,'check_sensitive_word','0',1,'是否检查敏感词',2),
  (0,'audit_status_default','1',1,'短信话术审核默认状态值',2);

-- ----------------------------
-- Table structure for aicall_audit_record
-- ----------------------------
CREATE TABLE `aicall_audit_record` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL COMMENT '所属企业id',
  `audit_user_id` int(10) unsigned NOT NULL COMMENT '审核人用户id',
  `type` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '1 话术 2 短信',
  `value` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '对应类型的数据的自增id',
  `reason` varchar(500) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '原因',
  `status` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '1 通过 2 未通过',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_eid_type_val` (`eid`,`type`,`value`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='资源审核记录表';

ALTER TABLE `script` ADD  `status` int(10) unsigned NOT NULL DEFAULT '1' COMMENT '审核状态 1 通过 2未通过 0 待审核';
ALTER TABLE `sms_template` ADD  `status` int(10) unsigned NOT NULL DEFAULT '1' COMMENT '审核状态 1 通过 2未通过 0 待审核';
ALTER TABLE `aicall_role` CHANGE `name` `name` VARCHAR(100)  CHARACTER SET utf8  COLLATE utf8_general_ci  NOT NULL  DEFAULT ''  COMMENT '角色名称';

ALTER TABLE `aicall_api_log` ADD `params` text COMMENT '请求参数' AFTER `api_name`;
/*57416*/
-- ALTER TABLE `outcall_task` ADD INDEX `start_time` (`start_time`) USING BTREE;
-- ALTER TABLE `outcall_task` ADD INDEX `complete_time` (`complete_time`) USING BTREE;
-- ALTER TABLE `outcall_task` ADD INDEX `enterprise_uid` (`enterprise_uid`) USING BTREE;

-- ALTER TABLE `enterprise_info` ADD INDEX `enterprise_id` (`enterprise_id`) USING BTREE;

-- ALTER TABLE `failed_callback` ADD INDEX `enterprise_uid` (`enterprise_uid`) USING BTREE;
-- ALTER TABLE `failed_callback` ADD INDEX `callback_times` (`callback_times`) USING BTREE;
/*58827*/
-- ----------------------------
-- Table structure for aicall_auth_rule
-- ----------------------------
DROP TABLE IF EXISTS `aicall_auth_rule`;
CREATE TABLE `aicall_auth_rule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '规则id,自增主键',
  `status` tinyint(2) unsigned NOT NULL DEFAULT 1 COMMENT '是否有效: 0:无效,1:有效',
  `parent_id` int(10) NOT NULL DEFAULT 0 COMMENT '父级',
  `order` int(10) NOT NULL DEFAULT 10000 COMMENT '排列权重',
  `type` varchar(30) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '权限规则分类，请加应用前缀,如admin_',
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '规则唯一英文标识,全小写',
  `param` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '额外url参数',
  `title` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '规则描述',
  `condition` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '规则附加条件',
  `is_show` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT '是否显示: 0不显示，1显示',
  `nav_icon` varchar(100) NOT NULL DEFAULT '' COMMENT '菜单ICON',
  `allow_auth` tinyint(2) NOT NULL DEFAULT '1' COMMENT '允许下放0 不允许1允许',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_unique_name` (`name`) USING BTREE COMMENT '权限规则名称唯一索引',
  KEY `index_auth_module` (`status`,`type`) USING BTREE COMMENT '权限索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='权限规则表';

-- ----------------------------
-- Records of aicall_auth_rule
-- ----------------------------
INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
	(1000, 1, 0, 10, '', 'module_statistics', '', '数据统计', '', 0, '', 1),
	(2000, 1, 0, 20, '', 'module_talk', '', '话术管理', '', 0, '', 1),
	(3000, 1, 0, 30, '', 'module_question', '', '问题库', '', 0, '', 1),
	(4000, 1, 0, 40, '', 'module_task', '', '任务管理', '', 0, '', 1),
	(5000, 1, 0, 50, '', 'module_authority', '', '权限管理', '', 0, '', 0),
	(6000, 1, 0, 60, '', 'module_log', '', '操作日志', '', 0, '', 0),

	(1001, 1, 1000, 10, '', 'statistics_view', '', '数据浏览', '', 0, '', 1),
	(1002, 1, 1000, 20, '', 'statistics_export', '', '导出报表', '', 0, '', 1),

	(2010, 1, 2000, 10, '', 'script', '', '话术', '', 0, '', 1),
	(2020, 1, 2000, 20, '', 'clusters', '', '聚类', '', 0, '', 1),
	(2030, 1, 2000, 30, '', 'fields', '', '变量', '', 0, '', 1),
	(2040, 1, 2000, 40, '', 'labels', '', '标签', '', 0, '', 1),
	(2050, 1, 2000, 50, '', 'messages', '', '短信', '', 0, '', 1),

	(2011, 1, 2010, 10, '', 'script_view', '', '话术浏览', '', 0, '', 1),
	(2012, 1, 2010, 20, '', 'script_edit', '', '话术编辑', '', 0, '', 1),
	(2013, 1, 2010, 30, '', 'script_del', '', '话术删除', '', 0, '', 1),
	(2014, 1, 2010, 40, '', 'script_add', '', '话术新建', '', 0, '', 1),
	(2015, 1, 2010, 50, '', 'script_check', '', '话术审核', '', 0, '', 1),

	(2021, 1, 2020, 10, '', 'cluster_view', '', '聚类浏览', '', 0, '', 1),
	(2022, 1, 2020, 20, '', 'cluster_edit', '', '聚类编辑', '', 0, '', 1),
	(2023, 1, 2020, 30, '', 'cluster_del', '', '聚类删除', '', 0, '', 1),
	(2024, 1, 2020, 40, '', 'cluster_add', '', '聚类新建', '', 0, '', 1),
	(2025, 1, 2020, 50, '', 'cluster_export', '', '导入/导出', '', 0, '', 1),

	(2031, 1, 2030, 10, '', 'field_view', '', '变量浏览', '', 0, '', 1),
	(2032, 1, 2030, 20, '', 'field_edit', '', '变量编辑', '', 0, '', 1),
	(2033, 1, 2030, 30, '', 'field_del', '', '变量删除', '', 0, '', 1),
	(2034, 1, 2030, 40, '', 'field_add', '', '变量新建', '', 0, '', 1),

	(2041, 1, 2040, 10, '', 'label_view', '', '标签浏览', '', 0, '', 1),
	(2042, 1, 2040, 20, '', 'label_edit', '', '标签编辑', '', 0, '', 1),
	(2043, 1, 2040, 30, '', 'label_del', '', '标签删除', '', 0, '', 1),
	(2044, 1, 2040, 40, '', 'label_add', '', '标签新建', '', 0, '', 1),
	(2045, 1, 2040, 50, '', 'label_export', '', '导入/导出', '', 0, '', 1),

	(2051, 1, 2050, 10, '', 'message_view', '', '短信浏览', '', 0, '', 1),
	(2052, 1, 2050, 20, '', 'message_edit', '', '短信编辑', '', 0, '', 1),
	(2053, 1, 2050, 30, '', 'message_del', '', '短信删除', '', 0, '', 1),
	(2054, 1, 2050, 40, '', 'message_add', '', '短信新建', '', 0, '', 1),
	(2055, 1, 2050, 50, '', 'message_check', '', '短信审核', '', 0, '', 1),

	(3001, 1, 3000, 10, '', 'question_view', '', '问题浏览', '', 0, '', 1),
	(3002, 1, 3000, 20, '', 'question_edit', '', '问题编辑', '', 0, '', 1),
	(3003, 1, 3000, 30, '', 'question_del', '', '问题删除', '', 0, '', 1),
	(3004, 1, 3000, 40, '', 'question_add', '', '问题新建', '', 0, '', 1),
	(3005, 1, 3000, 50, '', 'question_export', '', '导入/导出', '', 0, '', 1),

	(4001, 1, 4000, 10, '', 'task_view', '', '任务浏览', '', 0, '', 1),
	(4002, 1, 4000, 20, '', 'task_edit', '', '任务编辑', '', 0, '', 1),
	(4003, 1, 4000, 30, '', 'task_del', '', '任务删除', '', 0, '', 1),
	(4004, 1, 4000, 40, '', 'task_add', '', '任务新建', '', 0, '', 1),
	(4005, 1, 4000, 50, '', 'task_export', '', '任务详情导出', '', 0, '', 1),
	(4006, 1, 4000, 60, '', 'task_action', '', '任务开启/暂停', '', 0, '', 1);

-- ----------------------------
-- Table structure for aicall_auth_access
-- ----------------------------
DROP TABLE IF EXISTS `aicall_auth_access`;
CREATE TABLE `aicall_auth_access` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` int(10) unsigned NOT NULL COMMENT '角色',
  `auth_rule_id` int(10) NOT NULL DEFAULT 0 COMMENT '规则ID',
  PRIMARY KEY (`id`),
  KEY `index_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='权限授权表';
-- ----------------------------
-- Records of aicall_auth_access
-- ----------------------------
INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
	(1, 2000),
	(1, 2010),
	(1, 2050),
	(1, 2015),
	(1, 2055),
	(2, 1000),
	(2, 1001),
	(2, 1002),
	(2, 2000),
	(2, 2010),
	(2, 2011),
	(2, 2012),
	(2, 2013),
	(2, 2014),
	(2, 2020),
	(2, 2021),
	(2, 2022),
	(2, 2023),
	(2, 2024),
	(2, 2025),
	(2, 2030),
	(2, 2034),
	(2, 2031),
	(2, 2032),
	(2, 2033),
	(2, 2040),
	(2, 2041),
	(2, 2042),
	(2, 2043),
	(2, 2044),
	(2, 2045),
	(2, 2050),
	(2, 2051),
	(2, 2052),
	(2, 2053),
	(2, 2054),
	(2, 3000),
	(2, 3001),
	(2, 3002),
	(2, 3003),
	(2, 3004),
	(2, 3005),
	(2, 4000),
	(2, 4001),
	(2, 4002),
	(2, 4003),
	(2, 4004),
	(2, 4005),
	(2, 4006),
	(2, 5000),
	(2, 6000);

-- ----------------------------
-- Table structure for aicall_auth_action
-- ----------------------------
DROP TABLE IF EXISTS `aicall_auth_action`;
CREATE TABLE `aicall_auth_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '规则id,自增主键',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '是否有效(0:无效,1:有效)',
  `type` varchar(30) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '权限规则分类',
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '规则唯一英文标识,全小写',
  `param` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '额外url参数',
  `title` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '规则描述',
  `is_log` int(3) unsigned NOT NULL DEFAULT '0' COMMENT '是否需要记录日志',
  `template` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '默认日志模板',
  `model` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '模块名称',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`) USING BTREE,
  KEY `module` (`status`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='权限行为表';
-- ----------------------------
-- Records of aicall_auth_action
-- ----------------------------
INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
	(1, 1, '', '/aicall/script/getScriptsByPageParams', '', '话术列表', 0, '', 'script'),
	(2, 1, '', '/aicall/question/exportQuestionByTypeAndData', '', '问题导出', 1, '导出-问题-批量', 'question'),
	(3, 1, '', '/aicall/enterprise/importData:type=1', '', '导入聚类', 1, '导入-聚类-批量', 'script'),
	(5, 1, '', '/aicall/question/getQuestionById', '', '问题详情查看', 0, '', 'question'),
	(96, 1, '', '/aicall/file/uploadAudioFile', '', '上传录音', 0, '', 'script'),
	(97, 1, '', '/aicall/file/getAudioFileById', '', '试听', 0, '', 'script'),
	(98, 1, '', '/aicall/script/setMixTtsDataListByJson', '', '设置mix_id', 0, '', 'script'),
	(99, 1, '', '/aicall/script/getFieldsByPageParams', '', '变量列表', 0, '', 'script'),
	(100, 1, '', '/aicall/enterprise/getGroups', '', '获取人工坐席列表', 0, '', 'enterprise'),
	(101, 1, '', '/aicall/script/getMessagesByPageParams', '', '短信列表', 0, '', 'script'),
	(102, 1, '', '/aicall/script/getScriptContentDetailById', '', '话术详情', 0, '', 'script'),
	(103, 1, '', '/aicall/task/getTasks', '', '任务列表', 0, '', 'task'),
	(117, 1, '', '/aicall/task/getGlobalKeywordByTaskId', '', '获取全语境关键词', 0, '', 'task'),
	(118, 1, '', '/aicall/task/getTaskStatistics', '', '任务统计结果', 0, '', 'task'),
	(119, 1, '', '/aicall/task/getTaskCluesByTaskId:!export', '', '任务详情线索', 0, '', 'task'),
	(120, 1, '', '/aicall/task/getRecord', '', '查看通话记录', 0, '', 'task'),
	(121, 1, '', '/aicall/task/getRecordUrl', '', '获取通话记录试听地址', 0, '', 'task'),
	(122, 1, '', '/aicall/script/getLabelsByPageParams', '', '标签列表', 0, '', 'script'),
	(123, 1, '', '/aicall/task/deleteTasks', '', '删除任务', 1, '删除-任务', 'task'),
	(124, 1, '', '/aicall/task/deleteRecords', '', '删除线索', 1, '删除-通话记录', 'task'),
	(125, 1, '', '/aicall/enterprise/getAccountCount', '', '获取外呼机器人', 0, '', 'enterprise'),
	(126, 1, '', '/aicall/enterprise/getCallNumbers', '', '获取外呼号码', 0, '', 'enterprise'),
	(127, 1, '', '/aicall/task/checkFile', '', '任务校验', 0, '', 'task'),
	(128, 1, '', '/aicall/task/saveTask:id', '', '编辑任务', 1, '编辑-任务-${task_name}', 'task'),
	(129, 1, '', '/aicall/enterprise/getGlobalStatistics', '', '查看数据统计', 0, '', 'statistic'),
	(130, 1, '', '/aicall/enterprise/getStatisticsReport', '', '数据统计导出报表', 1, '导出-报表', 'statistic'),
	(131, 1, '', '/aicall/question/getQuestionsByWhere', '', '问题列表', 0, '', 'question'),
	(132, 1, '', '/aicall/script/getClustersByPageParams', '', '聚类列表', 0, '', 'script'),
	(133, 1, '', '/aicall/script/deleteScriptById', '', '删除话术', 1, '删除-话术', 'script'),
	(134, 1, '', '/aicall/script/deleteClusterByIds', '', '删除聚类', 1, '删除-聚类', 'script'),
	(135, 1, '', '/aicall/script/deleteFieldById', '', '删除变量', 1, '删除-变量', 'script'),
	(136, 1, '', '/aicall/script/deleteLabelByIds', '', '删除标签', 1, '删除-标签', 'script'),
	(137, 1, '', '/aicall/script/deleteMessageById', '', '删除短信', 1, '删除-短信', 'script'),
	(138, 1, '', '/aicall/script/setScriptByData:!id', '', '新建话术', 1, '新增-话术-${title}', 'script'),
	(139, 1, '', '/aicall/script/setClusterByData:!id', '', '新建聚类', 1, '新增-聚类-${title}', 'script'),
	(140, 1, '', '/aicall/script/setFieldByData:!id', '', '新建变量', 1, '新增-变量-${title}', 'script'),
	(141, 1, '', '/aicall/script/setLabelByData:!id', '', '新建标签', 1, '新增-标签-${title}', 'script'),
	(142, 1, '', '/aicall/script/setMessageByData:!id', '', '新建短信', 1, '新增-短信-${title}', 'script'),
	(143, 1, '', '/aicall/script/exportScriptRelateByTypeAndData:method=3', '', '导出聚类', 1, '导出-聚类-批量', 'script'),
	(144, 1, '', '/aicall/question/deleteQuestionsByIds', '', '删除问题', 1, '删除-问题', 'question'),
	(145, 1, '', '/aicall/task/controlTask:operate=start', '', '任务开始', 1, '暂停-任务', 'task'),
	(146, 1, '', '/aicall/task/recallByType', '', '重呼', 0, '', 'task'),
	(147, 1, '', '/aicall/script/setClusterByData:id', '', '编辑聚类', 1, '编辑-聚类-${title}', 'script'),
	(148, 1, '', '/aicall/script/setFieldByData:id', '', '编辑变量', 1, '编辑-变量-${title}', 'script'),
	(149, 1, '', '/aicall/script/setLabelByData:id', '', '编辑标签', 1, '编辑-标签-${title}', 'script'),
	(150, 1, '', '/aicall/script/setMessageByData:id', '', '编辑短信', 1, '编辑-短信-${title}', 'script'),
	(151, 1, '', '/aicall/script/setScriptByData:id', '', '编辑话术', 1, '编辑-话术-${title}', 'script'),
	(152, 1, '', '/aicall/question/setQuestionByData:id', '', '编辑问题', 1, '编辑-问题-${standard}', 'question'),
	(153, 1, '', '/aicall/question/setQuestionByData:!id', '', '新建问题', 1, '新增-问题-${standard}', 'question'),
	(154, 1, '', '/aicall/task/saveTask:!id', '', '新建任务', 1, '新增-任务-${task_name}', 'task'),
	(155, 1, '', '/aicall/enterprise/importData:type=2', '', '导入问题', 1, '导入-问题-批量', 'question'),
	(156, 1, '', '/aicall/enterprise/importData:type=3', '', '导入标签', 1, '导入-标签-批量', 'script'),
	(157, 1, '', '/aicall/enterprise/importData:type=4', '', '导入变量', 0, '', 'script'),
	(158, 1, '', '/aicall/script/exportScriptRelateByTypeAndData:method=5', '', '导出标签', 1, '导出-标签-批量', 'script'),
	(159, 1, '', '/aicall/script/exportScriptRelateByTypeAndData:method=6', '', '导出变量', 0, '导出-变量-批量', 'script'),
	(161, 1, '', '/aicall/enterprise/getFreeAccount', '', '获取空闲机器人数', 0, '', 'enterprise'),
	(162, 1, '', '/aicall/authority/getAuthority', '', '获取权限树', 0, '', 'authority'),
	(163, 1, '', '/aicall/authority/getRolesByWhere', '', '获取角色列表', 0, '', 'authority'),
	(164, 1, '', '/aicall/authority/getRoleById', '', '获取角色详情', 0, '', 'authority'),
	(165, 1, '', '/aicall/authority/setRoleByData:!id', '', '新建角色', 1, '新增-角色-${name}', 'authority'),
	(166, 1, '', '/aicall/authority/setRoleByData:id', '', '编辑角色', 1, '编辑-角色-${name}', 'authority'),
	(167, 1, '', '/aicall/authority/deleteRolesByIds', '', '删除角色', 1, '删除-角色', 'authority'),
	(168, 1, '', '/aicall/authority/controlRolesByIds:status=1', '', '启用角色', 1, '启用-角色', 'authority'),
	(169, 1, '', '/aicall/authority/setUserByData:!id', '', '新建账户', 1, '新增-账户-${username}', 'authority'),
	(170, 1, '', '/aicall/authority/setUserByData:id', '', '编辑账户', 1, '编辑-账号-${username}', 'authority'),
	(171, 1, '', '/aicall/authority/getUsersByWhere', '', '获取账户列表', 0, '', 'authority'),
	(172, 1, '', '/aicall/authority/resetPasswordById', '', '重置密码', 0, '', 'authority'),
	(173, 1, '', '/aicall/authority/deleteUsersByIds', '', '删除账户', 1, '删除-账户', 'authority'),
	(174, 0, '', '/aicall/identity/login', '', '登录', 1, '', 'login'),
	(175, 1, '', '/aicall/task/getTaskCluesByTaskId:export=1', '', '导出任务通话记录', 1, '外呼-导出通话记录', 'task'),
	(176, 1, '', '/aicall/task/getTaskCluesByTaskId:export=2', '', '导出任务通话文本', 1, '外呼-导出通话文本', 'task'),
	(177, 1, '', '/aicall/task/controlTask:operate=pause', '', '任务暂停', 1, '开始-任务', 'task'),
	(178, 1, '', '/aicall/authority/controlRolesByIds:status=0', '', '禁用角色', 1, '禁用-角色', 'authority');

-- ----------------------------
-- Table structure for aicall_auth_rule_action
-- ----------------------------
DROP TABLE IF EXISTS `aicall_auth_rule_action`;
CREATE TABLE `aicall_auth_rule_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rule_id` int(10) NOT NULL DEFAULT 0 COMMENT '权限ID',
  `action_id` int(10) NOT NULL DEFAULT 0 COMMENT '行为ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='权限行为表';
-- ----------------------------
-- Records of aicall_auth_rule_action
-- ----------------------------
INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
	(1001, 129),
	(1001, 1),
	(1001, 103),
	(1002, 130),
	(2011, 1),
	(2012, 122),
	(2012, 101),
	(2012, 102),
	(2012, 98),
	(2012, 99),
	(2012, 132),
	(2012, 96),
	(2012, 97),
	(2012, 100),
	(2012, 151),
	(2013, 133),
	(2014, 97),
	(2014, 96),
	(2014, 99),
	(2014, 122),
	(2014, 101),
	(2014, 98),
	(2014, 132),
	(2014, 100),
	(2014, 138),
	(2021, 132),
	(2022, 147),
	(2023, 134),
	(2024, 139),
	(2025, 143),
	(2025, 3),
	(2031, 99),
	(2032, 148),
	(2033, 135),
	(2034, 140),
	(2041, 122),
	(2042, 149),
	(2043, 136),
	(2044, 141),
	(2045, 158),
	(2045, 156),
	(2051, 101),
	(2052, 150),
	(2053, 137),
	(2054, 142),
	(3001, 131),
	(3001, 1),
	(3002, 5),
	(3002, 131),
	(3002, 98),
	(3002, 100),
	(3002, 101),
	(3002, 102),
	(3002, 99),
	(3002, 96),
	(3002, 97),
	(3002, 122),
	(3002, 1),
	(3002, 152),
	(3003, 144),
	(3004, 131),
	(3004, 99),
	(3004, 101),
	(3004, 102),
	(3004, 1),
	(3004, 98),
	(3004, 122),
	(3004, 100),
	(3004, 153),
	(3005, 155),
	(3005, 2),
	(4001, 117),
	(4001, 120),
	(4001, 121),
	(4001, 118),
	(4001, 119),
	(4001, 103),
	(4001, 146),
	(4001, 124),
	(4001, 1),
	(4001, 122),
	(4001, 176),
	(4002, 128),
	(4002, 127),
	(4002, 125),
	(4002, 126),
	(4002, 1),
	(4003, 123),
	(4004, 125),
	(4004, 126),
	(4004, 1),
	(4004, 127),
	(4004, 154),
	(4005, 175),
	(4006, 177),
	(4006, 145),
	(4006, 161),
	(5000, 168),
	(5000, 167),
	(5000, 162),
	(5000, 173),
	(5000, 164),
	(5000, 163),
	(5000, 172),
	(5000, 171),
	(5000, 169),
	(5000, 170),
	(5000, 178);
/*58828*/
ALTER TABLE `outcall_task` ADD COLUMN `delete_flag` tinyint(4) NOT NULL DEFAULT 0 COMMENT '软删除标记 0:未删除 1:已删除';
ALTER TABLE `outcall_clue` ADD COLUMN `delete_flag` tinyint(4) NOT NULL DEFAULT 0 COMMENT '软删除标记 0:未删除 1:已删除';

RENAME TABLE `aicall_calllog_horary_statistics` TO `aicall_calllog_horary_statistics_history`;
CREATE TABLE `aicall_calllog_horary_statistics` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `enterprise_uid` int(10) unsigned DEFAULT '0' COMMENT '企业id',
  `task_id` int(10) unsigned DEFAULT '0' COMMENT '任务id',
  `script_id` int(10) unsigned DEFAULT '0' COMMENT '话术id',
  `horary_date` varchar(10) DEFAULT '0' COMMENT '时间例如(20181224_08)',
  `total_call_duration` int(10) unsigned DEFAULT '0' COMMENT '通话总时长',
  `total_call_count` int(10) unsigned DEFAULT '0' COMMENT '通话总数量',
  `message_count` int(10) unsigned DEFAULT '0' COMMENT '短信发送数量',
  `manual_failed` int(10) unsigned DEFAULT '0' COMMENT '转接失败数量',
  `manual_success` int(10) unsigned DEFAULT '0' COMMENT '转接成功数量',
  `connected_call_count` int(10) unsigned DEFAULT '0' COMMENT '接通数量',
  `intention_a_count` int(10) unsigned DEFAULT '0' COMMENT '意向性a数量',
  `intention_b_count` int(10) unsigned DEFAULT '0' COMMENT '意向性b数量',
  `intention_c_count` int(10) unsigned DEFAULT '0' COMMENT '意向性c数量',
  `intention_d_count` int(10) unsigned DEFAULT '0' COMMENT '意向性d数量',
  `intention_e_count` int(10) unsigned DEFAULT '0' COMMENT '意向性e数量',
  `intention_f_count` int(10) unsigned DEFAULT '0' COMMENT '意向性f数量',
  `intention_g_count` int(10) unsigned DEFAULT '0' COMMENT '意向性g数量',
  `intention_h_count` int(10) unsigned DEFAULT '0' COMMENT '意向性h数量',
  `intention_i_count` int(10) unsigned DEFAULT '0' COMMENT '意向性i数量',
  `result_call_answered` int(10) unsigned DEFAULT '0' COMMENT '通话状态-接听',
  `result_call_answered_and_hangup` int(10) unsigned DEFAULT '0' COMMENT '通话状态-接听并挂机',
  `result_call_not_answered` int(10) unsigned DEFAULT '0' COMMENT '通话状态-未接听',
  `result_call_failed` int(10) unsigned DEFAULT '0' COMMENT '通话状态-外呼失败',
  `result_call_rejected` int(10) unsigned DEFAULT '0' COMMENT '通话状态-拒接',
  `result_call_number_not_find` int(10) unsigned DEFAULT '0' COMMENT '通话状态-空号',
  `result_call_shutdown` int(10) unsigned DEFAULT '0' COMMENT '通话状态-关机',
  `result_call_downtime` int(10) unsigned DEFAULT '0' COMMENT '通话状态-停机',
  `result_call_out_of_service` int(10) unsigned DEFAULT '0' COMMENT '通话状态-不在服务区',
  `result_call_busy_line` int(10) unsigned DEFAULT '0' COMMENT '通话状态-占线',
  `result_call_switch_number_arrears` int(10) unsigned DEFAULT '0' COMMENT '通话状态-总机关机',
  `result_call_restriction` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '外呼限制',
  `is_end` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '统计是否完成，1未完成，2完成',
  `duration_count` varchar(5000) DEFAULT '' COMMENT '0-120秒通话数量',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_date_eid` (`horary_date`,`enterprise_uid`,`task_id`) USING BTREE COMMENT '用户日期唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='通话记录统计分时表';
/*58997*/
ALTER TABLE `aicall_enterprise_sms` ADD `gateway_id` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '网关id';
INSERT INTO `aicall_sms_gateway` VALUES ('tenggao', '滕高', 'http://jk.106api.cn/smsUTF8.aspx');
/*59192*/
UPDATE `aicall_auth_action` SET `template` = '编辑-话术-${title}-${log}' WHERE `id` = 151;
UPDATE `aicall_auth_action` SET `template` = '编辑-问题-${standard}-${log}' WHERE `id` = 152;
UPDATE `aicall_auth_action` SET `template` = '编辑-任务-${task_name}-${log}' WHERE `id` = 128;

UPDATE `aicall_auth_action` SET `template` = '删除-话术-${log}' WHERE `id` = 133;
UPDATE `aicall_auth_action` SET `template` = '删除-聚类-${log}' WHERE `id` = 134;
UPDATE `aicall_auth_action` SET `template` = '删除-变量-${log}' WHERE `id` = 135;
UPDATE `aicall_auth_action` SET `template` = '删除-标签-${log}' WHERE `id` = 136;
UPDATE `aicall_auth_action` SET `template` = '删除-短信-${log}' WHERE `id` = 137;
UPDATE `aicall_auth_action` SET `template` = '删除-问题-${log}' WHERE `id` = 144;
UPDATE `aicall_auth_action` SET `template` = '删除-任务-${log}' WHERE `id` = 123;
UPDATE `aicall_auth_action` SET `template` = '删除-通话记录-${log}' WHERE `id` = 124;
UPDATE `aicall_auth_action` SET `template` = '删除-角色-${log}' WHERE `id` = 167;
UPDATE `aicall_auth_action` SET `template` = '删除-账户-${log}' WHERE `id` = 173;

UPDATE `aicall_auth_action` SET `template` = '开始-任务-${log}' WHERE `id` = 145;
UPDATE `aicall_auth_action` SET `template` = '暂停-任务-${log}' WHERE `id` = 177;

UPDATE `aicall_auth_action` SET `template` = '启用-角色-${log}' WHERE `id` = 168;
UPDATE `aicall_auth_action` SET `template` = '禁用-角色-${log}' WHERE `id` = 178;

INSERT INTO `aicall_auth_rule` VALUES (4007, 1, 4000, 70, '', 'task_trycall', '', '任务试呼', '', 0, '', 1);
ALTER TABLE `aicall_auth_access` ADD UNIQUE KEY `index_auth_rule_id` (`auth_rule_id`, `role_id`) USING BTREE COMMENT '权限规则唯一索引';

INSERT INTO `aicall_auth_action`(`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`) VALUES (179, 0, '', '/aicall/identity/loginByMobile', '', '短信登录', 1, '短信登录', 'login');
/*59193*/
INSERT INTO `aicall_auth_action`(`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`) VALUES (180, 1, '', '/aicall/task/recall', '', '重呼', 0, '', 'task');

DELETE FROM `aicall_auth_rule_action` WHERE action_id=146 and rule_id=4001;
INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
(4006, 146),
(4006, 180);

ALTER TABLE `aicall_log` MODIFY COLUMN `message` varchar(1024) NOT NULL DEFAULT '' COMMENT '日志';
/*59944*/
ALTER TABLE `outcall_clue` DROP INDEX `index_phone`;
ALTER TABLE `outcall_clue` ADD INDEX `index_phone` (`phone`, `task_id`) USING BTREE;
ALTER TABLE `outcall_task` MODIFY COLUMN `auto_recall_interval` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '自动重呼间隔，可选值1-29718300，单位秒';

ALTER TABLE `aicall_global_blacklist` ADD COLUMN `eid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '企业id';

ALTER TABLE `aicall_global_blacklist` DROP INDEX `index_unique_mobile`;
ALTER TABLE `aicall_global_blacklist` ADD UNIQUE INDEX `index_unique_mobile`(`mobile`, `eid`) USING BTREE COMMENT '企业+手机号联合唯一索性';

INSERT INTO `aicall_auth_rule` VALUES
(7000, 1, 0, 35, '', 'module_blacklist', '', '黑名单', '', 0, '', 1),
(7001, 1, 7000, 10, '', 'blacklist_view', '', '号码查询', '', 0, '', 1),
(7002, 1, 7000, 20, '', 'blacklist_add', '', '号码新增', '', 0, '', 1),
(7003, 1, 7000, 30, '', 'blacklist_del', '', '号码删除', '', 0, '', 1),
(7004, 1, 7000, 40, '', 'blacklist_export', '', '导入', '', 0, '', 1),
(1003, 1, 1000, 30, '', 'statistics_expNumber', '', '导出号码清单', '', 0, '', 1);


INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`) VALUES
(2, 7000),
(2, 7001),
(2, 7002),
(2, 7003),
(2, 7004),
(2, 1003);

INSERT INTO `aicall_auth_action` VALUES
(181, 1, '', '/aicall/blacklist/setBlackCluesByData', '', '新增黑名单', 1, '新增-黑名单-手动添加', 'blacklist'),
(182, 1, '', '/aicall/blacklist/delBlackCluesById', '', '删除黑名单', 1, '删除-黑名单-${log}', 'blacklist'),
(183, 1, '', '/aicall/enterprise/importData:type=5', '', '导入黑名单', 1, '导入-黑名单-批量导入', 'blacklist'),
(184, 1, '', '/aicall/blacklist/getBlackClueByMobile', '', '查询黑名单', 0, '', 'blacklist'),
(185, 1, '', '/aicall/statistic/exportNumber', '', '导出号码清单', 1, '导出-号码清单', 'statistic');

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
 (7002, 181),
 (7003, 182),
 (7004, 183),
 (7001, 184),
 (1003, 185);

ALTER TABLE `calllog` ADD INDEX `index_duration` (`duration`) USING BTREE;

CREATE TABLE `aicall_no_match_item` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(11) NOT NULL DEFAULT '0' COMMENT '企业ID',
  `task_id` int(11) NOT NULL DEFAULT '0' COMMENT '任务id',
  `script_id` int(11) NOT NULL DEFAULT '0' COMMENT '话术id',
  `content` varchar(1000) NOT NULL DEFAULT '' COMMENT '单句内容',
  `state` tinyint(2) NOT NULL DEFAULT '0' COMMENT '0未处理，1已处理',
  `calllog_id` int(11) NOT NULL DEFAULT '0' COMMENT '通话任务ID',
  `sub_script` tinyint(4) NOT NULL DEFAULT '0' COMMENT '第几次出现',
  `callee_phone` varchar(20) NOT NULL DEFAULT '' COMMENT '被叫号码',
  `cc_number` varchar(100) NOT NULL DEFAULT '' COMMENT '通话CC_NUMBER',
  PRIMARY KEY (`id`),
  KEY `idx_eid_callog_id` (`eid`,`calllog_id`) USING BTREE COMMENT '企业id和calllog日志id索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='未匹配通话记录表';

ALTER TABLE `aicall_api_user` MODIFY COLUMN `secret` varchar(255) NOT NULL DEFAULT '' COMMENT '密钥';

ALTER TABLE `script` ADD `prologue` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '开场白状态 0 默认自建 1 开启开场白';

ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `result_call_blacklist` int(10) NOT NULL DEFAULT 0 COMMENT '黑名单限制' AFTER `result_call_restriction`;

ALTER TABLE `aicall_calllog_label` MODIFY COLUMN `label` varchar(1000) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '标签';
/*60210*/
INSERT INTO `aicall_auth_rule` VALUES
(2016, 1, 2010, 50, '', 'script_export', '', '导入/导出', '', 0, '', 1);

INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`) VALUES
(2, 2016);

INSERT INTO `aicall_auth_action` VALUES
(186, 1, '', '/aicall/script/importScriptByData', '', '话术导入', 1, '导入-话术', 'script'),
(187, 1, '', '/aicall/script/exportScriptByData', '', '话术导出', 1, '导出-话术', 'script');

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
(2016, 186),
(2016, 187);

ALTER TABLE `question` ADD COLUMN `intention_hit` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '意向性命中数量';
/*60211*/
ALTER TABLE outcall_clue ADD COLUMN TTS_cached SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0';
CREATE TABLE aicall_tts_file_cache (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  TTS_text VARCHAR(500) NOT NULL,
  TTS_version_code INT(10) UNSIGNED NOT NULL,
  tts_src VARCHAR(500) NOT NULL,
  tts_duration INT(10) UNSIGNED NOT NULL,
  create_time INT(10) UNSIGNED NOT NULL,
  access_time INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`)
);
/*60212*/
ALTER TABLE `outcall_clue` MODIFY COLUMN `TTS_cached` SMALLINT(5) UNSIGNED NOT NULL default '0';
/*#aicall_sms_gateway#*/
INSERT INTO `aicall_sms_gateway` VALUES ('angwang', '昂网', 'http://47.104.84.72:8513/sms/Api/ReturnJson/Send.do');

ALTER TABLE `aicall_tts_version` ADD COLUMN `tts_voice_name` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '音频声音名称(请求时使用)';
ALTER TABLE `aicall_tts_version` ADD COLUMN `tts_company_id` int(10) unsigned NOT NULL DEFAULT '1' COMMENT 'tts 的厂商id 1 标贝 2 阿里';

-- ----------------------------
-- Table structure for aicall_tts_company
-- ----------------------------
CREATE TABLE `aicall_tts_company` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `company_title` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '后台显示名字',
  `company_name` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '厂商真实名字',
  `order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '排序数字',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='tts厂商配置表';
INSERT INTO `aicall_tts_company` VALUES (1, '厂商B', '标贝', 2);
INSERT INTO `aicall_tts_company` VALUES (2, '厂商A', '阿里', 1);
/*62018*/
ALTER TABLE aicall_tts_file_cache ADD INDEX tts_text_version_code (TTS_text, TTS_version_code);
ALTER TABLE `outcall_task` ADD COLUMN `auto_recall_timeInterval` int(10) NOT NULL DEFAULT 0 COMMENT '自动重呼的定时时间' AFTER `auto_recall_times`;
/*62019*/
/*#aicall_config#*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
  (0, 'system_title', '米话智能语音机器人-企业后台', 1, '系统企业后台标题', 3),
  (0, 'system_admin_title', '米话智能语音机器人-管理平台', 1, '系统管理平台标题', 3),
  (0, 'system_name', '智能语音机器人', 1, '运营后台界面名称', 3),
  (0, 'system_admin_name', 'Emicnet管理平台', 1, '运维后台界面名称', 3),
  (0, 'system_copyright', '南京易米云通网络科技有限公司', 1, '版权企业名称', 3),
  (0, 'system_record_no', '京ICP备07015048号-4', 1, '备案号', 3),
  (0, 'system_customized_control', 0, 1, '定制化需求开关', 3);

UPDATE `aicall_config` SET `type` = 3 WHERE `key` = 'web_miitbeian_url';
/*62895*/
UPDATE `aicall_tts_version` SET `tts_version_desc` = '客服女声', `order` = 1, `api_version` = 1, `tts_voice_name` = '智能客服_静静', `tts_company_id` = 1 WHERE `tts_version_code` = 1;
UPDATE `aicall_tts_version` SET `tts_version_desc` = '客服男声', `order` = 3, `api_version` = 1, `tts_voice_name` = '智能客服_小金', `tts_company_id` = 1 WHERE `tts_version_code` = 2;
UPDATE `aicall_tts_version` SET `tts_version_desc` = '邻家女声', `order` = 2, `api_version` = 2, `tts_voice_name` = '标准合成_邻家女声_娇娇', `tts_company_id` = 1 WHERE `tts_version_code` = 3;
/*#aicall_tts_version#*/
INSERT INTO `aicall_tts_version`(`tts_version_code`, `tts_version_desc`, `order`, `api_version`, `tts_voice_name`, `tts_company_id`) VALUES (4, '亲和女声', 4, 1, 'Aixia', 2);
INSERT INTO `aicall_tts_version`(`tts_version_code`, `tts_version_desc`, `order`, `api_version`, `tts_voice_name`, `tts_company_id`) VALUES (5, '标准男声', 5, 1, 'Aida', 2);
/*62995*/
ALTER TABLE `calllog` DROP INDEX `index_enterprise_uid`;
ALTER TABLE `calllog` ADD INDEX `index_hangup_time` (`enterprise_uid`,`hangup_time`) USING BTREE COMMENT '挂机时间索引';
/*62996*/
ALTER TABLE `aicall_text_tts_version` DROP INDEX `index_unique_text_tts_id`;
ALTER TABLE `aicall_text_tts_version` ADD COLUMN `extension` int(10) unsigned NOT NULL DEFAULT '5' COMMENT '属性参数 暂用于表示语速 1-9 默认5';
ALTER TABLE `aicall_text_tts_version` ADD UNIQUE KEY `index_unique_text_tts_id` (`text_tts_id`,`tts_version_code`,`extension`) USING BTREE COMMENT 'tts合成唯一索引';
/*63266*/
ALTER TABLE `aicall_tts_file_cache` ADD COLUMN `extension` INT(10) UNSIGNED NOT NULL DEFAULT '5' AFTER `access_time`;
ALTER TABLE `aicall_tts_file_cache` DROP INDEX `tts_text_version_code` , ADD INDEX `tts_text_version_code` (`TTS_text`(255) ASC, `TTS_version_code` ASC, `extension` ASC);
ALTER TABLE `script` ADD COLUMN `precheck` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '外呼预处理' AFTER `prologue`;
ALTER TABLE `custom_field` ADD COLUMN `test_value` varchar(100) NOT NULL COMMENT '变量测试值默认';
ALTER TABLE `custom_field` ADD COLUMN `serve_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '对应服务的id';
ALTER TABLE `aicall_mix_tts_order` ADD COLUMN `extension` int(10) unsigned NOT NULL DEFAULT '5' COMMENT '属性参数 暂用于表示语速 1-9 默认5';

-- ----------------------------
-- Table structure for aicall_field_serve
-- ----------------------------
CREATE TABLE `aicall_field_serve` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业id',
  `name` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '名称',
  `url` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '服务地址',
  `params` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '入参参数',
  `comment` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '备注',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `error_msg` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '错误提示语句',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='api变量服务支持表';
/*63267*/
CREATE TABLE `aicall_calllog_continuous_sync` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `enterprise_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0',
  `clue_id` int(10) unsigned NOT NULL DEFAULT '0',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0',
  `call_count` int(10) unsigned NOT NULL DEFAULT '0',
  `caller_phone` varchar(20) NOT NULL DEFAULT '',
  `callee_phone` varchar(20) NOT NULL DEFAULT '',
  `duration` smallint(5) unsigned NOT NULL DEFAULT '0',
  `calllog_txt` text,
  `cc_number` varchar(100) NOT NULL DEFAULT '',
  `script_name` varchar(50) NOT NULL DEFAULT '',
  `label` varchar(300) NOT NULL DEFAULT '',
  `call_result` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `intention_type` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `call_time` int(10) unsigned NOT NULL DEFAULT '0',
  `manual_status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `answer_time` int(10) unsigned NOT NULL DEFAULT '0',
  `hangup_time` int(10) unsigned NOT NULL DEFAULT '0',
  `call_record_url` varchar(400) NOT NULL DEFAULT '',
  `match_global_keyword` varchar(500) NOT NULL DEFAULT '',
  `transfer_number` varchar(20) NOT NULL DEFAULT '',
  `transfer_duration` smallint(5) unsigned NOT NULL DEFAULT '0',
  `message_count` tinyint(4) NOT NULL DEFAULT '0' COMMENT '发送短信数量',
  `hangup_node_text` VARCHAR(500) NOT NULL DEFAULT '',
  `buttons` varchar(50) NOT NULL DEFAULT '' COMMENT '按键，JSON',
  `pid` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'calllog id',
  PRIMARY KEY (`id`),
  KEY `index_pte` (`pid`, `task_id`, `enterprise_uid`) USING BTREE,
  KEY `index_clue_id` (`clue_id`, `task_id`, `enterprise_uid`) USING BTREE,
  KEY `index_create_time` (`create_time`, `task_id`, `enterprise_uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `aicall_calllog_extension` (
  `calllog_id` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'calllog id',
  `hangup_type` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '1:系统挂断 2:客户挂断',
  PRIMARY KEY (`calllog_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='企业通话日志扩展表';

ALTER TABLE `outcall_task` ADD `call_cnt`  INT(10) UNSIGNED   DEFAULT '1';

CREATE TABLE `emergency_contacter` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '任务ID',
  `outcall_clue_id` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '线索ID',
  `phone` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '号码',
  `finished` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '结束标志，暂时未用',
  `role` VARCHAR(30) NOT NULL DEFAULT '' COMMENT '角色',
  `script_id` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '话术ID',
  `create_time` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_outcall_clue_id` (`outcall_clue_id`) USING BTREE COMMENT '企业线索id索引'
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='紧急联系人表';
/*63268*/
ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `result_call_check` int(10) NOT NULL DEFAULT 0 COMMENT '校验限制' AFTER `result_call_blacklist`;
/*63269*/
ALTER TABLE `aicall_calllog_extension` ADD COLUMN `order_status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '客户确定开户状态，实指OC调用了开户结口为强列意愿，拒访状态实指客户强列拒绝状态标记 0：默认值（中性） 1：强列意愿 2：拒访';
ALTER TABLE `aicall_calllog_extension` ADD COLUMN `order_result` int(2) unsigned NULL COMMENT '客户跟进结果，实指OC调用接口的data里的code值';
/*63270*/
ALTER TABLE `outcall_clue` DROP INDEX `index_create_time`;
ALTER TABLE `outcall_clue` ADD INDEX `index_create_time` (`task_id`, `create_time`) USING BTREE;
/*65077*/
ALTER TABLE `script` ADD COLUMN `collect_info` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '信息采集开关 0默认值关闭 1开启';
ALTER TABLE `question` MODIFY COLUMN `similar_question` MEDIUMTEXT NOT NULL;
/*65078*/
ALTER TABLE `outcall_task` DROP INDEX `enterprise_uid`;
ALTER TABLE `outcall_task` ADD INDEX `enterprise_uid` (`enterprise_uid`, `uuid`) USING BTREE;
ALTER TABLE `outcall_task` MODIFY COLUMN `name` varchar(500) NOT NULL DEFAULT '';
CREATE TABLE IF NOT EXISTS `aicall_oc_callback` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `ip` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '请求ip',
 `api` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '回调接口',
 `api_data` text COLLATE utf8_unicode_ci COMMENT '回调数据',
 `api_result` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '回调结果',
 `time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '请求时间',
 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='OC服务器回调数据表';
/*65603*/
/*#aicall_config#*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
  (0,'script_precheck_count_limit', 5, 1, '话术呼叫前检查数量限制', 2);

ALTER TABLE `outcall_task` ADD COLUMN `priority` tinyint(2) UNSIGNED NOT NULL DEFAULT 0 COMMENT '任务优先级，优先级别分别为1,2,3,4,5';
ALTER TABLE `outcall_task` ADD COLUMN `valid_start_date` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '外呼有效期开始日期';
ALTER TABLE `outcall_task` ADD COLUMN `valid_end_date` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '外呼有效期结束日期';
ALTER TABLE `outcall_task` ADD COLUMN `valid_start_time` varchar(20) NOT NULL DEFAULT '' COMMENT '外呼开始时间';
ALTER TABLE `outcall_task` ADD COLUMN `valid_end_time` varchar(20) NOT NULL DEFAULT '' COMMENT '外呼结束时间';
/*65604*/
ALTER TABLE `aicall_calllog_extension` ADD COLUMN `transfer_manual_cost` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '转人工等待时长';
ALTER TABLE `aicall_calllog_continuous_sync` ADD COLUMN `transfer_manual_cost` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '转人工等待时长';
/*65605*/

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (188, 1, '', '/aicall/task/getRecordsByTaskId:export=4', '', '导出反馈结果', 1, '导出-反馈结果', 'task'),
    (189, 1, '', '/aicall/task/exportRecordAudios', '', '录音批量导出', 1, '外呼-录音批量导出', 'task'),
    (190, 1, '', '/aicall/task/getRecordsByTaskId:!export', '', '任务详情查看', 1, '查看-任务详情', 'task');


INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
	(4008, 1, 4000, 51, '', 'task_export_text', '', '导出通话文本', '', 0, '', 1),
	(4009, 1, 4000, 52, '', 'task_export_audio', '', '批量导出录音', '', 0, '', 1),
	(4010, 1, 4000, 53, '', 'task_export_collect_info', '', '导出反馈结果', '', 0, '', 1);

INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`) VALUES (2, 4008);
INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`) VALUES (2, 4009);
INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`) VALUES (2, 4010);

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
(4008, 176),
(4009, 189),
(4010, 188),
(4001, 190);

DELETE FROM `aicall_auth_rule_action` WHERE action_id=176 and rule_id=4001;
UPDATE `aicall_auth_action` SET `name` = '/aicall/task/getRecordsByTaskId:export=1' WHERE `id` = 175;
UPDATE `aicall_auth_action` SET `name` = '/aicall/task/getRecordsByTaskId:export=2' WHERE `id` = 176;
/*65606*/
ALTER TABLE `outcall_clue` CHANGE COLUMN `alias` `alias` varchar(100) NOT NULL DEFAULT '' COMMENT '线索别名 clue_no';
/*66551*/
ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `manual_hangup` int(10) unsigned DEFAULT '0' COMMENT '转接中挂断数量';
/*66552*/
ALTER TABLE `outcall_task` CHANGE COLUMN `bound_switch_number` `bound_switch_number` varchar(500) NOT NULL DEFAULT '' COMMENT '总机号码';
ALTER TABLE `query_question_script` ADD INDEX `index_enterprise_uid` (`enterprise_uid`) USING BTREE;
ALTER TABLE `query_question_script` ADD INDEX `index_question_id` (`question_id`) USING BTREE;
ALTER TABLE `query_question_script` ADD INDEX `index_script_id` (`script_id`) USING BTREE;
/*67014*/
INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
	(8000, 1, 0, 41, '', 'module_callin', '', '呼入记录', '', 0, '', 1),
	(9000, 1, 0, 42, '', 'module_highrisk', '', '智能质检', '', 0, '', 1),
	(9001, 1, 9000, 10, '', 'high_risk_view', '', '高风险清单查看', '', 0, '', 1),
	(9002, 1, 9000, 20, '', 'high_risk_sign', '', '状态标记', '', 0, '', 1),
	(9003, 1, 9000, 30, '', 'risk_blacklist_add', '', '黑名单', '', 0, '', 1),
	(9004, 1, 9000, 40, '', 'high_risk_export', '', '导出', '', 0, '', 1),
	(9005, 1, 9000, 50, '', 'high_risk_rule', '', '设置规则', '', 0, '', 1);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (191, 1, '', '/aicall/highRisk/getHighRiskCustomerByPageParams:!export', '', '获取高风险清单列表', 1, '查看高风险清单', 'high_risk'),
    (192, 1, '', '/aicall/highRisk/updateStatusByIds', '', '处理高风险清单状态', 1, '处理高风险清单状态', 'high_risk'),
    (193, 1, '', '/aicall/highRisk/getHighRiskCustomerByPageParams:export=1', '', '高风险清单导出', 1, '高风险清单导出', 'high_risk'),
    (199, 1, '', '/aicall/highRisk/createHighRiskScanRuleByJson', '', '设置高风险规则', 1, '设置高风险规则', 'high_risk'),
    (200, 1, '', '/aicall/highRisk/deleteHighRiskScanRuleByJson', '', '设置高风险规则', 1, '设置高风险规则', 'high_risk'),
    (201, 1, '', '/aicall/enterprise/setConfig:intelligent_inspection_rule', '', '设置高风险规则', 1, '设置高风险规则', 'high_risk');

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
    (9001, 191),
    (9002, 192),
    (9003, 181),
    (9004, 193),
    (9005, 199),
    (9005, 200),
    (9005, 201);

INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`)
VALUES
    (2, 8000),
    (2, 9000),
    (2, 9001),
    (2, 9002),
    (2, 9003),
    (2, 9004),
    (2, 9005);

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
	(2060, 1, 2010, 60, '', 'incall_script', '', '呼入设置', '', 0, '', 1),
	(8001, 1, 8000, 10, '', 'incall_list', '', '呼入记录', '', 0, '', 1),
	(8002, 1, 8000, 20, '', 'export_incall_record', '', '导出通话记录', '', 0, '', 1),
	(8003, 1, 8000, 30, '', 'export_incall_record_content', '', '导出通话文本', '', 0, '', 1),
	(8004, 1, 8000, 40, '', 'export_incall_record_audio', '', '录音批量导出', '', 0, '', 1);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (194, 1, '', '/aicall/incall/setIncallScript', '', '呼入设置', 1, '呼入设置', 'script'),
    (195, 1, '', '/aicall/incall/search', '', '获取呼入记录列表', 1, '查看呼入记录', 'in_call'),
    (196, 1, '', '/aicall/incall/exportRecords', '', '导出通话记录', 1, '呼入-导出通话记录', 'in_call'),
    (197, 1, '', '/aicall/incall/exportRecordContents', '', '导出通话文本', 1, '呼入-导出通话文本', 'in_call'),
    (198, 1, '', '/aicall/incall/exportRecordAudios', '', '录音批量导出', 1, '呼入-录音批量导出', 'in_call');

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
    (2060, 194),
    (8001, 195),
    (8002, 196),
    (8003, 197),
    (8004, 198);

INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`)
VALUES
    (2, 2060),
    (2, 8001),
    (2, 8002),
    (2, 8003),
    (2, 8004);
/*67321*/
ALTER TABLE `aicall_no_match_item` ADD COLUMN `create_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '创建时间';
ALTER TABLE `aicall_no_match_item` ADD COLUMN `prev_ai_content` varchar(1000) NOT NULL DEFAULT '' COMMENT '上一个机器人对话内容';
ALTER TABLE `aicall_no_match_item` ADD COLUMN `call_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '通话时间';

ALTER TABLE `aicall_no_match_item` ADD INDEX `idx_eid_call_time` (`eid`,`call_time`) USING BTREE;
ALTER TABLE `aicall_no_match_item` ADD INDEX `idx_eid_script_id` (`eid`,`script_id`) USING BTREE;

CREATE TABLE IF NOT EXISTS `aicall_mismatch_maintain` (
 `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
 `eid` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '企业唯一标识',
 `script_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '话术唯一标识',
 `mismatch_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '表aicall_no_match_item记录唯一标识',
 `create_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '创建时间',
 PRIMARY KEY (`id`),
 KEY `index_eid_script` (`eid`, `script_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='未匹配对话维护记录表';

INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
  (0,'analysis_no_match_moudle_enabled','1',1,'未匹配问题模块控制',2),
  (0,'call_outin_moudle_enabled','0',1,'呼入呼出模块控制',2),
  (0, 'analysis_server_host', '39.105.98.221', 1, '对话分析服务器地址', 1),
  (0, 'analysis_server_port', '5002', 1, '对话分析服务器端口', 1),
  (0, 'analysis_server_protocol', 'http', 1, '对话分析服务器请求协议', 1);
/*67322*/
CREATE TABLE `aicall_high_risk_customer` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业id',
  `phone` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '电话号码',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术id',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务id',
  `calllog_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '通话记录id',
  `call_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '呼叫时间',
  `status` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '状态 1 已处理 0 未处理',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `cc_number` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '通话记录唯一id',
  `msg` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '原因',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_calllog_id` (`calllog_id`) USING BTREE COMMENT 'calllog_id唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='高风险客户表';

CREATE TABLE `aicall_high_risk_scan_rule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业id',
  `content` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '内容',
  `type` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '类型 1 包含关键字 2出现总次数',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='高风险客户表扫描规则';

CREATE TABLE `ic_account` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `enterprise_uid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `biz_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `idle` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `username` varchar(64) NOT NULL DEFAULT '',
  `realm` varchar(64) NOT NULL DEFAULT '',
  `from_domain` varchar(64) NOT NULL DEFAULT '',
  `from_user` varchar(64) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `gateway` varchar(64) NOT NULL DEFAULT '',
  `create_time` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='呼入式机器人账户表';

CREATE TABLE `ic_calllog` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `enterprise_uid` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '企业ID',
  `script_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '话术ID',
  `script_name` varchar(200) NOT NULL DEFAULT '' COMMENT '话术名称',
  `call_count` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '呼叫轮次',
  `caller_phone` varchar(20) NOT NULL DEFAULT '' COMMENT '主叫号码',
  `callee_phone` varchar(20) NOT NULL DEFAULT '' COMMENT '被叫号码',
  `duration` smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT '通话时长',
  `calllog_txt` text NOT NULL COMMENT '通话内容',
  `cc_number` varchar(100) NOT NULL DEFAULT '' COMMENT '通话标识',
  `call_result` tinyint(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT '通话结果',
  `create_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '创建时间',
  `call_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '呼叫时间',
  `answer_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '接听时间',
  `hangup_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '挂断时间',
  `call_record_url` text NOT NULL COMMENT '录音地址',
  `manual_status` tinyint(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT '转人工状态',
  `transfer_number` varchar(20) NOT NULL DEFAULT '' COMMENT '转人工座席号',
  `transfer_duration` smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT '转人工时长',
  `transfer_manual_cost` smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT '转人工等待时长',
  `message_count` tinyint(4) NOT NULL DEFAULT 0 COMMENT '发送短信数量',
  `buttons` varchar(50) NOT NULL DEFAULT '' COMMENT '按键，JSON',
  PRIMARY KEY (`id`),
  KEY `create_time` (`create_time`,`enterprise_uid`) USING BTREE,
  KEY `callee_phone` (`callee_phone`,`enterprise_uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='呼入记录表';

CREATE TABLE `ic_calllog_label` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `incall_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '呼入记录ID',
  `label_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '标签ID',
  `label` varchar(100) NOT NULL DEFAULT '' COMMENT '标签',
  `create_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `incall_id` (`incall_id`) USING BTREE,
  KEY `label_id` (`label_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='呼入记录标签表';
/*67323*/
/*#aicall_sms_gateway#*/
INSERT INTO `aicall_sms_gateway` VALUES ('dfyy', '东方易信', 'http://47.95.161.134:9002/df_httpserver/smsSend.do');
/*69241*/
ALTER TABLE `outcall_task` ADD COLUMN `total_call_minutes` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '通话总分钟数';
ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `total_call_minutes` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '通话总分钟数';
ALTER TABLE `aicall_calllog_extension` ADD COLUMN `call_state` tinyint(4) UNSIGNED NOT NULL DEFAULT 0 COMMENT '呼叫失败明细';
ALTER TABLE `aicall_calllog_continuous_sync` ADD COLUMN `call_state` tinyint(4) UNSIGNED NOT NULL DEFAULT 0 COMMENT '呼叫失败明细';
ALTER TABLE `ic_calllog` ADD COLUMN `call_state` tinyint(4) UNSIGNED NOT NULL DEFAULT 0 COMMENT '呼叫失败明细';
/*69242*/
UPDATE `aicall_auth_rule` SET `name` = 'module_highrisk' WHERE `id` = 9000;
UPDATE `aicall_config` SET `value` = '1' WHERE `key` = 'analysis_no_match_moudle_enabled';
-- ALTER TABLE `outcall_task` ADD COLUMN `start_method` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '启动方式；0：手动，1：预约，2：立即';
/*69243*/
UPDATE `aicall_tts_file_cache` SET `extension` = `extension`*10;
UPDATE `aicall_text_tts_version` SET `extension` = `extension`*10;
UPDATE `aicall_mix_tts_order` SET `extension` = `extension`*10;
/*69244*/
ALTER TABLE `aicall_calllog_extension` MODIFY COLUMN `call_state` smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT '呼叫失败明细';
ALTER TABLE `aicall_calllog_continuous_sync` MODIFY COLUMN `call_state` smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT '呼叫失败明细';
/*70118*/
CREATE TABLE `aicall_super_enterprise` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `super_name` varchar(100) NOT NULL DEFAULT '' COMMENT '超级企业名称',
  `status` tinyint(4) UNSIGNED NOT NULL DEFAULT 0 COMMENT '超级企业状态 0:关闭 1:开启',
  `create_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='超级企业';

CREATE TABLE `aicall_super_detail` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `super_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '超级企业id',
  `eid` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '企业id',
  `create_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `index_super_id` (`super_id`) USING BTREE,
  KEY `index_eid` (`eid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='超级企业详情';
/*70254*/
INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
	(4011, 1, 4000, 71, '', 'task_migration', '', '任务迁移', '', 0, '', 1);
INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`) VALUES (2, 4011);
INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (202, 1, '', '/aicall/task/changeTaskEnterprise', '', '任务迁移', 1, '任务迁移', 'task');
INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
    (4011, 202);
/*70255*/
/*#aicall_sms_gateway#*/
INSERT INTO `aicall_sms_gateway` VALUES ('yixintong', '一信通', 'https://api.ums86.com:9600/sms/Api/Send.do');

INSERT INTO `aicall_auth_rule` VALUES (4012, 1, 4000, 72, '', 'task_script', '', '话术说明', '', 0, '', 1);

INSERT INTO `aicall_auth_action` VALUES (203, 1, '', '/aicall/task/getSpeechFile', '', '话术说明', 1, '话术说明', 'task');

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`) VALUES (4012, 203);
/*70492*/
ALTER TABLE `aicall_calllog_horary_statistics` ADD `label_count` varchar(5000) NOT NULL DEFAULT '' COMMENT '标签统计';
/*70858*/
ALTER TABLE `outcall_clue` ADD INDEX index_alias(`alias`) USING BTREE;

CREATE TABLE `aicall_business_result_sync` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `clue_no` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '号码id',
  `order_result` tinyint(3) NOT NULL DEFAULT '0' COMMENT '办理结果：0-成功 1-业务办理中 2-办理失败',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间（时间 秒）',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='业务办理结果同步表';
/*70859*/
/*#aicall_sms_gateway#*/
INSERT INTO `aicall_sms_gateway` VALUES ('jinanqx', '济南千寻', 'http://47.99.227.82:8081/api/sms/send');
/*71551*/
UPDATE `aicall_auth_action` SET is_log = 1,template = '重呼-任务-${log}' where `id` = 146;
UPDATE `aicall_auth_action` SET is_log = 1,template = '重呼-任务-${log}' where `id` = 180;
UPDATE `aicall_auth_action` SET is_log = 0 where `id` = 203;
/*71810*/
CREATE TABLE `aicall_custom_field_pronunciation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `pronunciation_code` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '读法code',
  `pronunciation_desc` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '读法说明',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT '顺序',
  `support_tts_company_ids` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '支持的厂商id(逗号隔开) 1 标贝 2 阿里',
  `sample_text` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '示例文本',
  `sample_pronunciation` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '示例读法',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='变量读法配置表';

INSERT INTO `aicall_custom_field_pronunciation` (`pronunciation_code`, `pronunciation_desc`, `order`, `support_tts_company_ids`, `sample_text`, `sample_pronunciation`)
VALUES
	('ordinal', '电话号码', 1, '1,2', '01062552560', '零幺零 六二五五 二五六零'),
	('digit', '数字', 2, '1,2', '145', '一百四十五'),
	('carnum', '车牌', 3, '1,2', '苏A 12345', '苏哎一二三四五'),
	('name', '姓名', 4, '1,2', '她的曾用名是曾小凡', '她的曾用名是曾（zeng）小凡'),
	('address', '地址', 5, '2', '市台路388弄1107-1108号', '市台路三八八弄幺幺零七杠幺幺零八号'),
	('characters', '字符', 6, '2', '空中客车A330', '空中客车A 三 三 零'),
	('date', '日期', 7, '2', '2008年08月08号', '二零零八年八月八号'),
	('time', '时间', 8, '2', '10:20:30', '十点二十分三十秒'),
	('currency', '货币', 9, '2', '$12,000', '一万两千美元'),
	('measure', '计量单位', 10, '2', '120.56cm²', '一百二十点五六平方厘米');

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (10000, 1, 0, 43, '', 'module_robot', '', '机器人管理', '', 0, '', 0),
    (10001, 1, 10000, 10, '', 'robot_detail', '', '机器人详情', '', 0, '', 1),
    (10002, 1, 10000, 20, '', 'robot_license', '', '上传license', '', 0, '', 1);

INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`)
VALUES
    (2, 10000),
    (2, 10001),
    (2, 10002);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (204, 1, '', '/aicall/enterprise/getLicenseDetail', '', '机器人详情', 1, '查看-机器人管理列表', 'robot'),
    (205, 1, '', '/aicall/enterprise/importLicense', '', '上传license', 1, '上传license文件${log}', 'robot');

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
    (10001, 204),
    (10002, 205);

ALTER TABLE `aicall_config` MODIFY COLUMN `value` varchar(1000) NOT NULL DEFAULT '' COMMENT '值';
INSERT INTO `aicall_sms_gateway` VALUES ('baidu', '百度', '');
/*71925*/
CREATE TABLE `aicall_script_extension` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `script_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '话术id',
  `recall_gap` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '重呼间隔（小时）',
  `new_version_intention` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否启用新版意向性',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_script_id` (`script_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='话术扩展表';

CREATE TABLE `aicall_task_extension` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `task_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '任务id',
  `max_outcall_count` int(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT '最大外呼次数',
  `avg_outcall_time` int(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT '平均外呼时长（秒）',
  `allow_recall_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '可重呼时间（时间 秒）',
  `not_answered_count` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '最后一轮未接听数',
  `recall_estimated_time` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '最后一轮未接听重呼预计耗时',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_task_id` (`task_id`) USING BTREE,
  KEY `index_max_outcall_count` (`max_outcall_count`) USING BTREE,
  KEY `index_allow_recall_time` (`allow_recall_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='任务扩展表';

CREATE TABLE `aicall_analysis_calllog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `enterprise_uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业id',
  `enterprise_name` varchar(200) NOT NULL DEFAULT '' COMMENT '企业名称',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务id',
  `task_name` varchar(200) NOT NULL DEFAULT '' COMMENT '任务名称',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术id',
  `script_name` varchar(200) NOT NULL DEFAULT '' COMMENT '话术名称',
  `calllog_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '通话记录id',
  `callee_phone` varchar(20) NOT NULL DEFAULT '' COMMENT '客户号码',
  `call_result` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '通话结果  1: 接通后挂断，2: 通话成功（只要有交互则算通话成功,  3:未接通，4:呼叫异常',
  `call_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '呼叫时间（时间 秒）',
  `week` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '星期数字',
  `daily_time` time NOT NULL DEFAULT '00:00:00' COMMENT '时（几点呼叫的）',
  `duration` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '通话时长',
  `call_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '外呼的次数',
  `dialog_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '对话轮次',
  `label` varchar(300) NOT NULL DEFAULT '' COMMENT '标签',
  `match_type` varchar(300) NOT NULL DEFAULT '' COMMENT '匹配类型（问题库/聚类/静音/未匹配）',
  `match_value` varchar(300) NOT NULL DEFAULT '' COMMENT '匹配值',
  `last_text` varchar(300) NOT NULL DEFAULT '' COMMENT '机器人最后一句话',
  `intention_custom` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '意向客户（是，否。规则：标签 包含过几天发、成功结束1、成功结束2，属于意向客户）',
  `success_a` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '（是，否。包含标签 成功结束-A）',
  `success_b` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '（是，否。包含标签 成功结束-B）',
  `success_c` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '（是，否。包含标签 成功结束-C）',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '当前记录创建时间',
  PRIMARY KEY (`id`),
  KEY `index_enterprise_uid` (`enterprise_uid`) USING BTREE,
  KEY `index_task_id` (`task_id`) USING BTREE,
  KEY `index_script_id` (`script_id`) USING BTREE,
  KEY `index_calllog_id` (`calllog_id`) USING BTREE,
  KEY `index_callee_phone` (`callee_phone`) USING BTREE,
  KEY `index_call_time` (`call_time`) USING BTREE,
  KEY `index_call_result` (`call_result`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*#aicall_tts_version#*/
INSERT INTO `aicall_tts_version`(`tts_version_code`, `tts_version_desc`, `order`, `api_version`, `tts_voice_name`, `tts_company_id`) VALUES (6, '甜美女声', 6, 1, 'Xiaomei', 2);
ALTER TABLE `enterprise_info` ADD COLUMN `ccgeid` INT(10) UNSIGNED NULL DEFAULT 0 AFTER `oc_ip`;
/*72526*/
/*#aicall_config#*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES (0, 'robot_count_limit', 1000, 1, '企业最大机器人数', 2);
/*72527*/
ALTER TABLE `aicall_analysis_calllog` ADD COLUMN `param` varchar(300) NOT NULL DEFAULT '' COMMENT '渠道变量';
/*72528*/
ALTER TABLE `outcall_task` ADD COLUMN `department_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '部门ID';
ALTER TABLE `outcall_task` ADD COLUMN `user_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '用户ID';
ALTER TABLE `outcall_task` ADD INDEX `index_edu` (`enterprise_uid`, `department_id`, `user_id`) USING BTREE;

ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `department_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '部门ID';
ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `user_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '用户ID';
ALTER TABLE `aicall_calllog_horary_statistics` ADD INDEX `index_edu` (`enterprise_uid`, `department_id`, `user_id`) USING BTREE;

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (4013, 1, 4000, 21, '', 'task_custom_import', '', '任务编辑时导入客户', '', 1, '', 1),
    (4014, 1, 4000, 74, '', 'task_audio_download', '', '下载录音', '', 1, '', 1),
    (4015, 1, 4000, 75, '', 'task_audio_audition', '', '试听录音', '', 1, '', 1);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (206, 1, '', '/aicall/task/getRecordUrl:operate=1', '', '下载录音', 1, '下载录音', 'task'),
    (207, 1, '', '/aicall/task/getRecordUrl:operate=0', '', '试听录音', 1, '试听录音', 'task');

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
    (4013, 127),
    (4014, 206),
    (4015, 207);

INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`)
VALUES
    (2, 4013),
    (2, 4014),
    (2, 4015);
/*72529*/
/*#aicall_config#*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
	(0,'analysis_calllog_time','0',1,'挂机统计时间',2);
/*72530*/
ALTER TABLE `aicall_super_enterprise` ADD COLUMN `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '主企业ID' AFTER `super_name`;

ALTER TABLE `aicall_super_detail` ADD COLUMN `parent_eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父企业ID' AFTER `super_id`;

CREATE TABLE `aicall_user_department` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '用户ID',
  `department_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '部门ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户部门关系表';

CREATE TABLE `aicall_department` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键，部门id',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '所属企业ID',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '部门名称',
  `switch_number` varchar(255) NOT NULL DEFAULT '' COMMENT '总机号（外呼号码）',
  `account_num` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '智能外呼账号数量（机器人数量）',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '部门状态（0.不可用 1.正常 2.删除）',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_eid` (`eid`) USING BTREE,
  KEY `index_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='智能外呼部门信息表';

ALTER TABLE `account` ADD COLUMN `department_id` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '部门id' AFTER `enterprise_uid`;

ALTER TABLE `account` ADD INDEX index_department_id (`department_id`);
/*72531*/
ALTER TABLE `aicall_super_enterprise` ADD INDEX index_eid (`eid`);
ALTER TABLE `aicall_super_enterprise` ADD COLUMN `allowed_task_move` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否允许任务迁移 1:允许 0:不允许';
/*72532*/
CREATE TABLE `aicall_calllog_analysis_records` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `calllog_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'calllog表主键id',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务id',
  `task_name` varchar(120) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `callee_phone` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '被叫号码',
  `analysis_text` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '质检用户文本',
  `analysis_result` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '质检结果 1:意向客户 2:问题库-中等意向 3:静音-中等意向 4:人工审核 5:问题库-人工审核 6:静音-人工审核',
  `outcall_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '外呼时间（时间 秒）',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_calllog_id` (`calllog_id`) USING BTREE,
  KEY `index_analysis_result` (`analysis_result`) USING BTREE,
  KEY `index_outcall_time` (`outcall_time`) USING BTREE,
  KEY `index_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='通话记录质检结果表';
/*73889*/
CREATE TABLE `aicall_script_resource_relate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业唯一ID ',
  `type` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '类型 1 话术 2 聚类 3 变量 4 标签 5 短信 6 问题库 7 服务 8 音频',
  `src_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '总公司使用资源id',
  `des_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '子公司使用资源id',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_eid_src_des` (`eid`,`src_id`,`des_id`,`type`) USING BTREE COMMENT '各种资源对应的版本只会有一份'
) ENGINE=InnoDB AUTO_INCREMENT=2541 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='话术资源推送关系表';

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (208, 1, '', '/aicall/script/pushScript', '', '话术推送', 1, '${log}', 'script'),
    (209, 1, '', '/aicall/department/getDepartmentList', '', '查看部门列表', 1, '查看部门列表', 'department'),
    (210, 1, '', '/aicall/department/setDepartment:!department_id', '', '新建部门', 1, '新建部门“${name}”', 'department'),
    (211, 1, '', '/aicall/department/setDepartment:department_id', '', '编辑部门', 1, '编辑部门“${name}”', 'department'),
    (212, 1, '', '/aicall/department/deleteDepartment', '', '删除部门', 1, '删除部门“${log}”', 'department'),
    (213, 1, '', '/aicall/enterprise/getApiKey', '', '查看API管理内容', 1, '查看API管理内容', 'api'),
    (214, 1, '', '/aicall/enterprise/setConfig', '', '编辑回调地址', 1, '编辑回调地址“${api_callback_domain}”', 'api'),
    (215, 1, '', '/aicall/enterprise/deleteIpFromWhiteList', '', '编辑白名单', 1, '编辑白名单', 'api'),
    (216, 1, '', '/aicall/enterprise/setIpWhiteListByIp', '', '编辑白名单', 1, '编辑白名单', 'api');

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (11000, 1, 0, 44, '', 'module_api', '', 'API管理', '', 0, '', 0),
    (11001, 1, 11000, 10, '', 'api_edit', '', 'API编辑', '', 0, '', 0);

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
    (11001, 213),
    (11001, 214),
    (11001, 215),
    (11001, 216);

INSERT INTO `aicall_auth_access`(`role_id`, `auth_rule_id`)
VALUES
    (2, 11000),
    (2, 11001);
ALTER TABLE `aicall_config` MODIFY COLUMN `value` varchar(5000) NOT NULL DEFAULT '' COMMENT '值';
/*73890*/
INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (217, 1, '', '/aicall/task/getTaskCluesByTaskId:export=1', '', '任务详情线索', 0, '', 'task');

INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
    (4001, 217);
/*74096*/
UPDATE `aicall_auth_action` SET `model`='authority' WHERE `id` IN (209,210,211,212);
UPDATE `aicall_auth_rule` SET `allow_auth`='0' WHERE `id` = 11000;
/*74097*/
INSERT INTO `aicall_auth_rule_action`(`rule_id`, `action_id`)
VALUES
    (4001, 161);
/*74210*/
ALTER TABLE `enterprise_info` MODIFY COLUMN `province_pinyin`  varchar(50) NOT NULL DEFAULT '';

/*74582*/
/*#aicall_config#aicall_auth_action#aicall_auth_rule#aicall_auth_access#aicall_auth_rule_action#*/
ALTER TABLE `aicall_mix_tts_order` ADD COLUMN `speed_type` INT(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT '语速类型 0 默认语速 1 自定义语速';
ALTER TABLE `script` ADD COLUMN `default_speed` int(10) UNSIGNED NOT NULL DEFAULT '50' COMMENT '默认语速50';
UPDATE `aicall_mix_tts_order` SET `speed_type` = 0 where `extension` = 50;
/*74613*/
ALTER TABLE `aicall_high_risk_scan_rule` MODIFY COLUMN `content` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '内容';
ALTER TABLE `aicall_high_risk_customer` ADD COLUMN `black_add` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '是否自动增加黑名单 0否 1是';
ALTER TABLE `aicall_high_risk_customer` ADD COLUMN `type` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '类型 1关键词 2多次关键词 3骂人 4标签 5意向性 6任务状态';
INSERT INTO `aicall_auth_action` VALUES
(218, 1, '', '/aicall/blacklist/export', '', '黑名单导出', 1, '黑名单导出', 'blacklist');

ALTER TABLE `aicall_global_blacklist` ADD INDEX `index_eid_create_time` (`eid`, `create_time`) USING BTREE;
INSERT INTO `aicall_auth_action` VALUES
(219, 1, '', '/aicall/highRisk/updateBlackStatusByIds', '', '高风险新增黑名单', 1, '质检号码加入黑名单', 'high_risk');
/*74614*/
ALTER TABLE `enterprise_info` MODIFY COLUMN `switch_number` varchar(10000) NOT NULL DEFAULT '' COMMENT '企业总机号，json';
/*74615*/
ALTER TABLE `aicall_user` ADD COLUMN `employee_id` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '工号';
/*74616*/
INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
       (4016, 1, 4000, 61, '', 'task_scheduled_time', '', '预约任务', '', 0, '', 1),
       (4017, 1, 4000, 62, '', 'task_time', '', '外呼/休息时间设置', '', 0, '', 1);

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
       (2, 4016),
       (2, 4017);

UPDATE `aicall_auth_rule` SET `title` = '任务开启/暂停/重新呼叫' WHERE `id` = 4006;
/*74617*/
ALTER TABLE `script` ADD COLUMN `priority` int(10) unsigned NOT NULL DEFAULT '3' COMMENT '任务优先级，优先级别分别为1,2,3,4,5 默认为3';
/*74618*/
INSERT INTO `aicall_auth_action` VALUES
(220, 1, '', '/aicall/script/setPriorityByData', '', '优先级设置', 1, '设置话术优先级', 'script');

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
       (2017, 1, 2010, 51, '', 'script_priority', '', '优先级设置', '', 0, '', 1);

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
       (2, 2017);

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (2017, 220);
/*74619*/
INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (7005, 1, 7000, 50, '', 'blacklist_download', '', '导出', '', 0, '', 1);

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
    (2, 7005);

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (7005, 218);
/*74620*/
UPDATE `aicall_auth_rule` SET `title` = '导入' WHERE `id` = 2025;
UPDATE `aicall_auth_rule` SET `title` = '导入' WHERE `id` = 3005;
/*74621*/
ALTER TABLE `calllog` MODIFY COLUMN `buttons` varchar(200) NOT NULL DEFAULT '' COMMENT '按键，JSON';
ALTER TABLE `aicall_calllog_continuous_sync` MODIFY COLUMN `buttons` varchar(200) NOT NULL DEFAULT '' COMMENT '按键，JSON';
ALTER TABLE `ic_calllog` MODIFY COLUMN `buttons` varchar(200) NOT NULL DEFAULT '' COMMENT '按键，JSON';
/*74622*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
    (0,'call_frequency_cicle_limit','365',1,'拨打管理最大周期天数',2),
    (0,'call_frequency_time_limit','30',1,'拨打管理最大外呼次数',2);
/*74623*/
CREATE TABLE `aicall_knowledge_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `gname` varchar(50) NOT NULL DEFAULT '' COMMENT '分组名',
  `pid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父分组id,如果就是第一级分组,则为0',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_pid` (`pid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库所属组表';

INSERT INTO `aicall_knowledge_group` (`id`, `gname`, `pid`) VALUES (1, '通用', 0);

CREATE TABLE `aicall_knowledge_library` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `lname` varchar(50) NOT NULL DEFAULT '' COMMENT '知识库名',
  `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '知识库描述',
  `gid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '所属分组id',
  `version_code` int(5) unsigned NOT NULL DEFAULT '0' COMMENT '最新发布的版本号(如果没有则为0)',
  `release_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最新发布时间',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_gid` (`gid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库表';

CREATE TABLE `aicall_knowledge_version` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `library_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库id',
  `version_code` int(5) unsigned NOT NULL DEFAULT '1' COMMENT '版本号从1开始每次+1',
  `remark` varchar(300) NOT NULL DEFAULT '' COMMENT '版本说明',
  `status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '版本状态：0.草稿 1.已发布 2.已下线',
  `release_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发布时间',
  `offline_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '下线时间',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_lid_code` (`library_id`,`version_code`) USING BTREE COMMENT '知识库版本唯一索引',
  KEY `index_lid_status` (`library_id`,`status`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库版本表';

CREATE TABLE `aicall_knowledge_template_cluster` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `library_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库id',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '聚类名称',
  `content` text NOT NULL COMMENT '聚类内容，格式为数组json',
  `remark` varchar(300) NOT NULL DEFAULT '' COMMENT '聚类说明',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库聚类模板表';

CREATE TABLE `aicall_knowledge_template_cluster_snapshot` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `library_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库id',
  `version_code` int(5) unsigned NOT NULL DEFAULT '1' COMMENT '版本号',
  `template_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '模板id',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '聚类名称',
  `content` text NOT NULL COMMENT '聚类内容，格式为数组json',
  `remark` varchar(300) NOT NULL DEFAULT '' COMMENT '聚类说明',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库聚类模板快照表';

CREATE TABLE `aicall_knowledge_template_question` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `library_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库id',
  `standard_question` varchar(30) NOT NULL DEFAULT '' COMMENT '标准问题',
  `similar_question` mediumtext NOT NULL COMMENT '相似问题列表，格式为数组json',
  `answer_text` varchar(400) NOT NULL DEFAULT '' COMMENT '回答的文字',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_standard_question` (`standard_question`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库问题库模板表';

CREATE TABLE `aicall_knowledge_template_question_snapshot` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `library_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库id',
  `version_code` int(5) unsigned NOT NULL DEFAULT '1' COMMENT '版本号',
  `template_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '模板id',
  `standard_question` varchar(30) NOT NULL DEFAULT '' COMMENT '标准问题',
  `similar_question` mediumtext NOT NULL COMMENT '相似问题列表，格式为数组json',
  `answer_text` varchar(400) NOT NULL DEFAULT '' COMMENT '回答的文字',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_standard_question` (`standard_question`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库问题库模板快照表';

CREATE TABLE `aicall_knowledge_version_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `library_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库id',
  `version_code` int(5) unsigned NOT NULL DEFAULT '1' COMMENT '版本号',
  `template_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '模板id',
  `snapshot_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '快照id',
  `resource_type` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '资源类型：1.聚类 2.问题库',
  `action_type` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '操作类型：0.复制 1.新建 2.编辑 3.删除',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_lid_code` (`library_id`,`version_code`) USING BTREE COMMENT '知识库版本唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库版本操作表';

CREATE TABLE `aicall_knowledge_push_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `library_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库id',
  `version_code` int(5) unsigned NOT NULL DEFAULT '1' COMMENT '版本号',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业唯一ID ',
  `template_cluster_ids` varchar(2500) NOT NULL DEFAULT '' COMMENT '推送的模板聚类ids,逗号隔开',
  `template_question_ids` varchar(2500) NOT NULL DEFAULT '' COMMENT '推送的模板问题库ids,逗号隔开',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_lid_code_eid` (`library_id`,`version_code`,`eid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库企业推送历史表';

CREATE TABLE `aicall_knowledge_template_to_enterprise` (
  `library_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库id',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业id',
  `template_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '知识库模板id(aicall_knowledge_template_cluster或aicall_knowledge_template_question)',
  `enterprise_resource_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业资源id(cluster或question表id)',
  `resource_type` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '资源类型：1.聚类 2.问题库',
  `status` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '更新状态：0.待更新 1.已更新',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  KEY `index_library_id` (`library_id`) USING BTREE COMMENT '知识库id'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='知识库模板id与企业资源id映射表';

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (12000, 1, 0, 31, '', 'module_knowledge', '', '知识库', '', 0, '', 1),
    (12001, 1, 12000, 10, '', 'knowledge_view', '', '知识库浏览', '', 0, '', 1),
    (12002, 1, 12000, 20, '', 'knowledge_detail', '', '知识库查看', '', 0, '', 1),
    (12003, 1, 12000, 30, '', 'knowledge_update_cluster', '', '更新聚类', '', 0, '', 1),
    (12004, 1, 12000, 40, '', 'knowledge_ignore_cluster', '', '忽略聚类', '', 0, '', 1),
    (12005, 1, 12000, 50, '', 'knowledge_update_question', '', '更新问题', '', 0, '', 1),
    (12006, 1, 12000, 60, '', 'knowledge_ignore_question', '', '忽略问题', '', 0, '', 1);

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
    (2, 12000),
    (2, 12001),
    (2, 12002),
    (2, 12003),
    (2, 12004),
    (2, 12005),
    (2, 12006);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (221, 1, '', '/aicall/knowledge/getUpdateKnowledgeLibrary', '', '查看知识库列表', 1, '查看“知识库列表”', 'knowledge'),
    (222, 1, '', '/aicall/knowledge/getUpdateResourceDetail', '', '查看知识库详情', 1, '查看“知识库详情”', 'knowledge'),
    (223, 1, '', '/aicall/knowledge/syncUpdate:resource_type=1', '', '更新聚类', 1, '更新聚类${log}', 'knowledge'),
    (224, 1, '', '/aicall/knowledge/syncUpdate:resource_type=2', '', '更新问题', 1, '更新问题${log}', 'knowledge'),
    (225, 1, '', '/aicall/knowledge/ignoreUpdateByIds:resource_type=1', '', '忽略聚类', 1, '忽略聚类${log}', 'knowledge'),
    (226, 1, '', '/aicall/knowledge/ignoreUpdateByIds:resource_type=2', '', '忽略问题', 1, '忽略问题${log}', 'knowledge');

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (12001, 221),
    (12002, 222),
    (12003, 223),
    (12004, 224),
    (12005, 225),
    (12006, 226);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (227, 1, '', '/aicall/script/tryCall', '', '话术试呼', 1, '${log}', 'script');

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (8005, 1, 8000, 50, '', 'incall_audio_audition', '', '试听录音', '', 0, '', 1),
    (8006, 1, 8000, 60, '', 'incall_audio_download', '', '下载录音', '', 0, '', 1),
    (8007, 1, 8000, 45, '', 'incall_record_detail', '', '通话详情', '', 0, '', 1);

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
    (2, 8005),
    (2, 8006),
    (2, 8007);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (228, 1, '', '/aicall/incall/getRecordAudioUrl:operate=0', '', '试听录音', 1, '试听录音', 'in_call'),
    (229, 1, '', '/aicall/incall/getRecordAudioUrl:operate=1', '', '下载录音', 1, '下载录音', 'in_call'),
    (230, 1, '', '/aicall/incall/getRecord', '', '通话详情', 1, '查看通话详情', 'in_call');

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (8005, 228),
    (8006, 229),
    (8007, 230);
/*74624*/
ALTER TABLE `aicall_knowledge_template_cluster` ADD INDEX `index_library_id` (`library_id`) USING BTREE;
ALTER TABLE `aicall_knowledge_template_cluster_snapshot` ADD INDEX `index_library_id` (`library_id`) USING BTREE;
ALTER TABLE `aicall_knowledge_template_question` ADD INDEX `index_library_id` (`library_id`) USING BTREE;
ALTER TABLE `aicall_knowledge_template_question_snapshot` ADD INDEX `index_library_id` (`library_id`) USING BTREE;
/*74625*/
DROP TABLE IF EXISTS `aicall_mobile_info`;
CREATE TABLE `aicall_mobile_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mobile_code` varchar(10) NOT NULL COMMENT '手机号代码',
  `area_code` varchar(10) NOT NULL DEFAULT '' COMMENT '区域区号',
  PRIMARY KEY (`id`),
  KEY `index_mobile_code` (`mobile_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='手机号信息表';
/*74626*/
/*#aicall_auth_action#aicall_auth_rule#aicall_auth_access#aicall_auth_rule_action#*/
UPDATE `aicall_config` SET `value` = '1' WHERE `key` = 'call_outin_moudle_enabled';

ALTER TABLE `aicall_global_blacklist` MODIFY COLUMN `mobile` varchar(100) NOT NULL DEFAULT '' COMMENT '手机号';
ALTER TABLE `outcall_clue` MODIFY COLUMN `phone` varchar(100) NOT NULL DEFAULT '' COMMENT '手机号';
ALTER TABLE `calllog` MODIFY COLUMN `callee_phone` varchar(100) NOT NULL DEFAULT '' COMMENT '手机号';
ALTER TABLE `aicall_high_risk_customer` MODIFY COLUMN `phone` varchar(100) NOT NULL DEFAULT '' COMMENT '手机号';

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (4018, 1, 4000, 80, '', 'task_clue_list', '', '客户线索', '', 0, '', 1),
    (4019, 1, 4000, 90, '', 'task_record_detail', '', '通话详情', '', 0, '', 1),
    (9006, 1, 9000, 60, '', 'high_risk_record_detail', '', '通话详情', '', 0, '', 1);

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
    (2, 4018),
    (2, 4019),
    (2, 9006);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (231, 1, '', '/aicall/highRisk/getRecord', '', '通话详情', 1, '查看通话详情', 'high_risk');

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (9006, 231);

UPDATE `aicall_auth_action` SET `title` = '客户线索' WHERE `id` = 119;
UPDATE `aicall_auth_action` SET `title` = '通话详情' WHERE `id` = 120;
UPDATE `aicall_auth_action` SET `title` = '客户线索导出' WHERE `id` = 217;
UPDATE `aicall_auth_rule_action` SET `rule_id` = 4018 WHERE `action_id` = 119;
UPDATE `aicall_auth_rule_action` SET `rule_id` = 4019 WHERE `action_id` = 120;
/*77892*/
DROP TABLE IF EXISTS `aicall_task_trash`;
CREATE TABLE `aicall_task_trash` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
    `eid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '企业唯一ID ',
    `department_id` int(10) unsigned DEFAULT 0 COMMENT '部门ID',
    `user_id` int(10) unsigned DEFAULT 0 COMMENT '用户ID',
    `task_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '任务ID',
    `task_name` varchar(120) NOT NULL DEFAULT '' COMMENT '任务名称',
    `start_time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '首次呼叫时间',
    `end_time` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '末次呼叫时间',
    `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
    PRIMARY KEY (`id`),
    KEY `eid` (`eid`) USING BTREE,
    KEY `create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='任务删除记录表';
ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `first_call_count` int(10) NOT NULL DEFAULT '0' COMMENT '一呼数据量';
ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `first_call_answered` int(10) NOT NULL DEFAULT '0' COMMENT '一呼接听数据量';

DROP TABLE IF EXISTS `aicall_callback_records`;
CREATE TABLE `aicall_callback_records` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(32) NOT NULL DEFAULT '' COMMENT '回调url',
  `headers` varchar(500) NOT NULL DEFAULT '' COMMENT '请求头',
  `params` text COLLATE utf8_unicode_ci COMMENT '格式化之后的请求参数',
  `result` text COLLATE utf8_unicode_ci COMMENT '回调结果',
  `status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '状态： 0.发起失败 2.回调失败',
  `platform` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '对应平台',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_status` (`status`),
  KEY `index_platform` (`platform`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='各平台经web回调结果记录表';

ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `intention_default_count` int(10) UNSIGNED NULL DEFAULT 0 AFTER `manual_success`;
ALTER TABLE `aicall_calllog_horary_statistics` ADD COLUMN `intention_j_count` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '意向性j数量' AFTER `intention_i_count`;
/*79172*/
DROP TABLE IF EXISTS `aicall_task_push_sms`;
CREATE TABLE `aicall_task_push_sms` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业ID',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务ID',
  `push_sms_type` tinyint(3) NOT NULL DEFAULT '0' COMMENT '消息类型(通知方式) 1：短信 2：企业微信 3：邮件',
  `push_sms_template_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '消息模板ID',
  `push_away` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '推送方式(通知时机) 0：任务完成后 1：立即',
  `push_condition` varchar(1024) NOT NULL DEFAULT '' COMMENT '推送目标，JSON数据，例：[{"intention_type":"1", "users":"1,2"}]',
  `status` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '推送状态，任务状态为已关闭或已锁定，该状态为不启用（需要更新该状态），0：不启用 1：启用',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_task_id` (`task_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务推送消息表';

DROP TABLE IF EXISTS `aicall_push_sms_template`;
CREATE TABLE `aicall_push_sms_template` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `sms_content` varchar(512) NOT NULL DEFAULT '' COMMENT '消息内容，支持参数',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='推送消息模板表';

DROP TABLE IF EXISTS `aicall_task_push_sms_history`;
CREATE TABLE `aicall_task_push_sms_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业ID',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务ID',
  `calllog_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '关联的通话记录ID，若为0，即为任务推送',
  `push_sms_type` tinyint(3) NOT NULL DEFAULT '0' COMMENT '消息类型 1：短信 2：企业微信 3：邮件',
  `push_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '推送时间',
  `push_content` varchar(1024) NOT NULL DEFAULT '' COMMENT '推送内容',
  `push_user` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '推送用户user_id',
  `push_status` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '推送状态，0：推送成功 1：推送失败',
  `push_ret` varchar(256) NOT NULL DEFAULT '' COMMENT '接口回执',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  PRIMARY KEY (`id`),
  KEY `index_task_id` (`eid`,`task_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务消息推送历史表';

DROP TABLE IF EXISTS `aicall_push_sms_config`;
CREATE TABLE `aicall_push_sms_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业ID',
  `push_sms_type` tinyint(3) NOT NULL DEFAULT '0' COMMENT '消息类型 1：短信 2：企业微信 3：邮件',
  `config` varchar(512) NOT NULL DEFAULT '' COMMENT '该消息类型必要配置',
  `status` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '启用状态 0：未开启 1：开启',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='推送消息配置表';

ALTER TABLE `aicall_user` ADD COLUMN `enterprise_wechat_account` varchar(64) NOT NULL DEFAULT '' COMMENT '企业微信账号';

INSERT INTO `aicall_push_sms_template` ( `id`, `sms_content` )
VALUES
  ( 1, '您好！您有%u位%s类意向客户产生，请及时查看！任务名称：%s，话术名称：%s，详情请登录企业后台查看%s' ),
  ( 2, '您好！您有%u位%s类意向客户产生，请及时查看！任务名称：%s，话术名称：%s，客户号码：%s，详情请登录企业后台查看%s');

ALTER TABLE `outcall_task` ADD COLUMN `batch_number` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '任务呼叫轮次';
UPDATE `aicall_auth_action` SET `template` = '${log}' WHERE `id` = 220;
/*79704*/
ALTER TABLE `aicall_field_serve` ADD COLUMN `type` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '服务执行时机 0 通话中 1通话前';
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
    (0,'watermark_length_limit','18',1,'企业水印最大长度',2),
    (0,'recall_count_limit','10',1,'最大重呼次数',2);
UPDATE `aicall_auth_rule` SET `title` = '企业设置' WHERE `id` = 11000;

ALTER TABLE `aicall_no_match_item` MODIFY COLUMN `callee_phone` varchar(100) NOT NULL DEFAULT '' COMMENT '被叫号码';
/*#outcall_task#*/
UPDATE outcall_task SET auto_recall_scenes = CONCAT('{"call_result":', auto_recall_scenes, '}') WHERE auto_recall_scenes like '[%';

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (11002, 1, 11000, 11, '', 'work_wechat_config', '', '企业微信设置', '', 0, '', 0);

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
    (2, 11002);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (232, 1, '', '/aicall/enterprise/getPushSmsConfig', '', '企业微信设置', 1, '企业微信设置', 'work_wechat_config');

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (11002, 232);

UPDATE `aicall_auth_rule` SET `title`='API设置' WHERE `id` = 11001;
ALTER TABLE `question` MODIFY COLUMN `mix_tts_id` varchar(400) NOT NULL DEFAULT '' COMMENT '混编tts编号';
ALTER TABLE `question` MODIFY COLUMN `jump_mix_tts_id` varchar(400) NOT NULL DEFAULT '' COMMENT '跳转文本混编tts编号';
ALTER TABLE `script` MODIFY COLUMN `tts_version_code` varchar(200) NOT NULL DEFAULT '' COMMENT '以逗号隔开多个tts版本号';
/*80562*/
INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (4002, 171),
    (4004, 171);
ALTER TABLE `aicall_calllog_extension`
ADD COLUMN `switch_number` varchar(20) NOT NULL DEFAULT '' COMMENT '主叫号码' AFTER `call_state`;
ALTER TABLE `aicall_calllog_continuous_sync`
ADD COLUMN `switch_number` varchar(20) NOT NULL DEFAULT '' COMMENT '主叫号码' AFTER `call_state`;

INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
    (0,'script_scenes_count_limit','10',1,'千人千面最大场景数',2);
/*80981*/
UPDATE `aicall_auth_rule_action` SET `action_id` = 219 WHERE `rule_id` = 9003;

UPDATE `aicall_auth_action` SET `name` = '/aicall/enterprise/getUpdateKnowledgeLibrary' WHERE `id` = 221;
UPDATE `aicall_auth_action` SET `name` = '/aicall/enterprise/getUpdateResourceDetail' WHERE `id` = 222;
UPDATE `aicall_auth_action` SET `name` = '/aicall/enterprise/syncUpdate:resource_type=1' WHERE `id` = 223;
UPDATE `aicall_auth_action` SET `name` = '/aicall/enterprise/syncUpdate:resource_type=2' WHERE `id` = 224;
UPDATE `aicall_auth_action` SET `name` = '/aicall/enterprise/ignoreUpdateByIds:resource_type=1' WHERE `id` = 225;
UPDATE `aicall_auth_action` SET `name` = '/aicall/enterprise/ignoreUpdateByIds:resource_type=2' WHERE `id` = 226;
UPDATE `aicall_config` SET `value` = 200 WHERE `key` = 'tts_text_length_limit';
/*81268*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
(0, 'call_record_export_count_limit', 20000, 1, '通话记录导出数量限制', 2);
/*81979*/
ALTER TABLE `aicall_callback_records` ADD COLUMN `class` varchar(128) NOT NULL DEFAULT '' COMMENT '回调实现类';
ALTER TABLE `aicall_callback_records` ADD COLUMN `retry_count` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '重新回调次数，超过3次不再回调';
ALTER TABLE `aicall_callback_records` MODIFY COLUMN `url` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '回调url';

ALTER TABLE `question` MODIFY COLUMN `answer_text` varchar(5012) NOT NULL DEFAULT '',
 MODIFY COLUMN`jump_text` varchar(5012) NOT NULL DEFAULT '';
UPDATE `aicall_config` SET `value` = '5000' WHERE `key` = 'question_answer_length_limit';
/*82089*/
DROP TABLE IF EXISTS `aicall_project_operator_form`;
CREATE TABLE `aicall_project_operator_form` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业ID',
  `extension_number` varchar(20) NOT NULL DEFAULT '' COMMENT '坐席分机号',
  `name` varchar(20) NOT NULL DEFAULT '' COMMENT '坐席姓名',
  `cc_number` varchar(255) NOT NULL DEFAULT '' COMMENT 'cc_number',
  `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
  `request_data` varchar(8096) NOT NULL DEFAULT '' COMMENT '请求报文 json',
  `response_data` varchar(2048) NOT NULL DEFAULT '' COMMENT '响应报文 json',
  `extra_data` varchar(2048) NOT NULL DEFAULT '' COMMENT '额外数据 json',
  `status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '状态 0：草稿 1:成功　2:失败',
  `retno` varchar(255) NOT NULL DEFAULT '' COMMENT '返回序列号',
  `retcode` varchar(20) NOT NULL DEFAULT '' COMMENT '返回状态',
  `retmsg` varchar(255) NOT NULL DEFAULT '' COMMENT '返回原因',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_cc_number` (`cc_number`) USING BTREE,
  KEY `index_mobile` (`mobile`) USING BTREE,
  KEY `index_retno` (`retno`) USING BTREE,
  KEY `index_eid` (`eid`,`update_time`) USING BTREE,
  KEY `index_status` (`status`,`eid`) USING BTREE,
  KEY `index_extension_number` (`extension_number`,`eid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='项目业务办理表';
INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
     (13000, 1, 0, 48, '', 'module_form', '', '工单管理', '', 0, '', 0);
-- INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`) VALUES (2, 13000);
/*82227*/
CREATE TABLE `aicall_script_cluster_relate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '企业id',
  `script_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '话术id',
  `cluster_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '聚类id',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  PRIMARY KEY (`id`),
  KEY `index_cluster_id` (`cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='智能对话话术聚类关联表';

CREATE TABLE `aicall_train_task` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业id',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术id',
  `train_id` varchar(512) NOT NULL DEFAULT '' COMMENT '训练id',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '训练任务名称',
  `train_user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '训练人user_id',
  `start_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '训练开始时间（秒）',
  `elapsed_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '训练总耗时（秒）',
  `status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '状态：0.待训练 1.训练中 2.待发布 3.已发布 4.可回退 5.下线中 6.已下线 7.待验证 8.训练失败',
  `train_status` tinyint(2) NOT NULL DEFAULT '0' COMMENT '训练状态(停留位置) 1.创建模型 2.导入数据 3.启动训练',
  `train_ret_message` varchar(255) NOT NULL DEFAULT '' COMMENT '训练异常信息',
  `serve_status` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '服务状态 0 未启用 1 启用 2 启动失败',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_script_id` (`script_id`),
  KEY `index_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='训练任务表';

CREATE TABLE `aicall_train_task_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `train_task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '训练任务id',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术id',
  `action` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '操作类型：1.新增文本 2.删除文本',
  `resource_type` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT '资源类型： 1.聚类 2.问题库',
  `resource_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '资源id',
  `change_content` mediumtext NOT NULL COMMENT '变更内容（json）',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `index_train_task_id` (`train_task_id`),
  KEY `index_script_id` (`script_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='训练任务操作表';

ALTER table `script` ADD COLUMN `train_id` varchar(512) NOT NULL DEFAULT '' COMMENT '正在使用的训练id';
ALTER table `script` ADD COLUMN `smart_dialogue_status` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT '智能对话状态：0.停用 1.启用';
ALTER table `script` ADD COLUMN `is_released` tinyint(2) unsigned NOT NULL DEFAULT 1 COMMENT '发布状态：0.未上线 1.已上线 2.已下线';

ALTER TABLE `cluster` ADD COLUMN `type` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '状态：0.普通聚类 1.智能对话话术聚类';
ALTER TABLE `cluster` ADD COLUMN `ai_intention` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'AI意图：按照16进制位运算， 1位：标签意图';

ALTER table `question` ADD COLUMN `type` tinyint(2) unsigned NOT NULL DEFAULT '0' COMMENT '状态：0.普通问题 1.智能对话话术问题';

ALTER table `aicall_mix_tts_order` ADD COLUMN `express` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '多种表达 默认从0开始增加';
/*83034*/
DROP TABLE IF EXISTS `aicall_manual_inspection_task`;
CREATE TABLE `aicall_manual_inspection_task` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
    `eid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '企业ID',
    `name` varchar(255) NOT NULL DEFAULT '' COMMENT '质检任务名称',
    `script_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '话术ID',
    `call_start_time` int(10) NOT NULL DEFAULT 0 COMMENT '外呼时间范围',
    `call_end_time` int(10) NOT NULL DEFAULT 0 COMMENT '外呼时间范围',
    `call_count` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT '外呼轮次',
    `intent_confidence` varchar(50) NOT NULL DEFAULT '' COMMENT '意图置信度 JSON',
    `match_text` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否匹配文本，1：未匹配文本、2：匹配文本',
    `intention_type` varchar(100) NOT NULL DEFAULT '' COMMENT '意向性 JSON，1：A类、2：B类、3：C类、4：D类、5：E类、6：F类、7：G类、8：H类、9：I类、10：J类',
    `hangup_type` tinyint(2) NOT NULL DEFAULT 0 COMMENT '挂断方，1：系统挂断、2：客户挂断',
    `manual_status` tinyint(3) NOT NULL DEFAULT 0 COMMENT '转人工状态，1：无空闲座席、2：转接成功、3：转接中挂断',
    `duration` varchar(100) NOT NULL DEFAULT '' COMMENT '通话时长范围 JOSN',
    `label` text NOT NULL COMMENT '标签查询范围 JOSN, eg: {"type":1-包含|2-不包含,"detail":[{"id":标签组ID,"text":["标签1","标签2"]}]}',
    `progress_rate` smallint(5) NOT NULL DEFAULT 0 COMMENT '进度',
    `status` tinyint(2) NOT NULL DEFAULT 1 COMMENT '状态，1：未解析、2：解析中、3：待质检、4：进行中、5：已完成',
    `deleted_time` int(10) NULL DEFAULT 0 COMMENT '删除时间（时间 秒）',
    `create_time` int(10) NULL DEFAULT 0 COMMENT '创建时间（时间 秒）',
    `update_time` int(10) NULL DEFAULT 0 COMMENT '更新时间（时间 秒）',
    PRIMARY KEY (`id`),
    KEY `index_eid_script_id` (`eid`, `script_id`) USING BTREE,
    KEY `index_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='人工质检任务表';

DROP TABLE IF EXISTS `aicall_manual_inspection_task_associate`;
CREATE TABLE `aicall_manual_inspection_task_associate` (
    `inspection_task_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '质检任务ID',
    `task_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '外呼任务ID',
    KEY `index_inspection_task_id` (`inspection_task_id`) USING BTREE,
    KEY `index_task_id` (`task_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='人工质检任务&外呼任务关联表';

DROP TABLE IF EXISTS `aicall_manual_inspection_dialog_detail`;
CREATE TABLE `aicall_manual_inspection_dialog_detail` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
    `eid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '企业ID',
    `inspection_task_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '质检任务ID',
    `script_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '话术ID',
    `script_node` varchar(255) NOT NULL DEFAULT '' COMMENT '话术节点ID',
    `script_node_name` varchar(255) NOT NULL DEFAULT '' COMMENT '话术节点名称',
    `task_id` int(10) NOT NULL DEFAULT 0 COMMENT '外呼任务ID',
    `calllog_id` int(10) NOT NULL DEFAULT 0 COMMENT '通话记录ID',
    `call_count` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT '外呼轮次',
    `callee_phone` varchar(100) NOT NULL DEFAULT '' COMMENT '客户号码',
    `cc_number` varchar(255) NOT NULL DEFAULT '' COMMENT '通话唯一标识',
    `robot_text` text NOT NULL COMMENT '机器人文本',
    `customer_text` text NOT NULL COMMENT '客户文本',
    `dialog_time` int(10) NOT NULL DEFAULT 0 COMMENT '对话时间（时间 秒）',
    `intent_confidence` decimal(3,2) NOT NULL DEFAULT 0.00 COMMENT '意图置信度',
    `intent_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '意图类型，1：聚类、2：问题库',
    `intent_id` int(10) NOT NULL DEFAULT 0 COMMENT '意图（聚类或问题库）ID',
    `match_text` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否匹配文本，1：未匹配文本、2：匹配文本',
    `status` tinyint(2) NOT NULL DEFAULT 1 COMMENT '状态，1：未质检、2：已质检',
    `inspection_user_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '质检人ID',
    `inspection_time` int(10) NULL DEFAULT 0 COMMENT '质检时间（时间 秒）',
    `create_time` int(10) NULL DEFAULT 0 COMMENT '添加时间（时间 秒）',
    `update_time` int(10) NULL DEFAULT 0 COMMENT '更新时间（时间 秒）',
    PRIMARY KEY (`id`),
    KEY `index_eid_task_confidence` (`eid`, `inspection_task_id`, `intent_confidence`) USING BTREE,
    KEY `index_eid_task_intent` (`eid`, `inspection_task_id`, `intent_id`) USING BTREE,
    KEY `index_eid_task_user` (`eid`, `inspection_task_id`, `inspection_user_id`) USING BTREE,
    KEY `index_eid_task_inspection_time` (`eid`, `inspection_task_id`, `inspection_time`) USING BTREE,
    KEY `index_eid_script_node` (`eid`, `script_node`) USING BTREE,
    KEY `index_sort` (`eid`, `inspection_task_id`, `task_id`, `calllog_id`, `dialog_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='人工质检对话详情表';

DROP TABLE IF EXISTS `aicall_manual_inspection_detail`;
CREATE TABLE `aicall_manual_inspection_detail` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
    `eid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '企业ID',
    `inspection_task_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '质检任务ID',
    `dialog_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '对话ID',
    `customer_text` text NOT NULL COMMENT '客户文本',
    `intent_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '意图类型，1：聚类、2：问题库',
    `intent_id` int(10) NOT NULL DEFAULT 0 COMMENT '意图（聚类或问题库）ID',
    `create_time` int(10) NULL DEFAULT 0 COMMENT '添加时间（时间 秒）',
    PRIMARY KEY (`id`),
    KEY `index_eid_task_dialog` (`eid`, `inspection_task_id`, `dialog_id`) USING BTREE,
    KEY `index_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='质检详情表';

UPDATE `aicall_auth_rule` SET `parent_id` = 14000, `name` = 'intelligent_inspection', `title` = '智能质检' WHERE `id` = 9000;

INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
    (14000, 1, 0, 42, '', 'module_highrisk', '', '质检管理', '', 0, '', 1),
    (14001, 1, 14000, 43, '', 'manual_inspection', '', '人工质检', '', 0, '', 1),
    (14002, 1, 14001, 10, '', 'task_create', '', '新建质检任务', '', 0, '', 1),
    (14003, 1, 14001, 20, '', 'task_modify', '', '编辑质检任务', '', 0, '', 1),
    (14004, 1, 14001, 30, '', 'task_delete', '', '删除质检任务', '', 0, '', 1),
    (14005, 1, 14001, 40, '', 'task_detail', '', '质检详情', '', 0, '', 1),
    (14006, 1, 14001, 50, '', 'dialog_status_update', '', '更新质检状态', '', 0, '', 1),
    (14007, 1, 14001, 60, '', 'dialog_intent_update', '', '修改意图', '', 0, '', 1),
    (14008, 1, 14001, 70, '', 'dialog_detail', '', '通话详情', '', 0, '', 1),
    (14009, 1, 14001, 80, '', 'dialog_audio_download', '', '下载录音', '', 0, '', 1),
    (14010, 1, 14001, 90, '', 'dialog_audio_listen', '', '试听录音', '', 0, '', 1);

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
    (2, 14000),
    (2, 14001),
    (2, 14002),
    (2, 14003),
    (2, 14004),
    (2, 14005),
    (2, 14006),
    (2, 14007),
    (2, 14008),
    (2, 14009),
    (2, 14010);

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
    (233, 1, '', '/aicall/ManualInspection/getTaskList', '', '质检任务浏览', 1, '质检任务浏览', 'manual_inspection'),
    (234, 1, '', '/aicall/ManualInspection/createTask', '', '新建质检任务', 1, '新建-质检任务-${name}-${log}', 'manual_inspection'),
    (235, 1, '', '/aicall/ManualInspection/modifyTask', '', '编辑质检任务', 1, '编辑-质检任务-${name}-${log}', 'manual_inspection'),
    (236, 1, '', '/aicall/ManualInspection/deleteTask', '', '删除质检任务', 1, '删除-质检任务-${log}', 'manual_inspection'),
    (237, 1, '', '/aicall/ManualInspection/changeDialogStatusByIds', '', '更新质检状态', 1, '更新质检状态', 'manual_inspection'),
    (238, 1, '', '/aicall/ManualInspection/saveDialogInspectionDetails', '', '修改意图', 1, '修改意图', 'manual_inspection'),
    (239, 1, '', '/aicall/ManualInspection/getRecord', '', '通话详情', 1, '查看通话详情', 'manual_inspection'),
    (240, 1, '', '/aicall/ManualInspection/getRecordUrl:operate=1', '', '下载录音', 1, '下载录音', 'manual_inspection'),
    (241, 1, '', '/aicall/ManualInspection/getRecordUrl:operate=0', '', '试听录音', 1, '试听录音', 'manual_inspection'),
    (242, 1, '', '/aicall/ManualInspection/getTaskDetailInfo', '', '质检详情', 1, '质检详情', 'manual_inspection');

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
    (14001, 233),
    (14002, 234),
    (14003, 235),
    (14004, 236),
    (14006, 237),
    (14007, 238),
    (14008, 239),
    (14009, 240),
    (14010, 241);
/*83282*/
CREATE TABLE `aicall_script_analysis` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业ID',
  `calllog_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'calllogID',
  `script_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '话术ID',
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务id',
  `script_node_name` varchar(200) NOT NULL DEFAULT '' COMMENT '节点名称',
  `script_node_id` varchar(200) NOT NULL DEFAULT '' COMMENT '节点id',
  `sentiment` varchar(200) NOT NULL DEFAULT '' COMMENT '情绪值 positive negative neutral',
  `sentiment_change` varchar(200) NOT NULL DEFAULT '' COMMENT '情绪变化 变好:positive 变坏:negative 不变:neutral',
  `hangup_status` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '是否为挂断节点 0 否 1 是',
  `call_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '外呼的次数',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间（时间 秒）',
  `hangup_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '挂断时间（时间 秒）',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='话术分析表';

CREATE TABLE `aicall_recharge_mobile` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '号码',
    `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
    PRIMARY KEY (`id`),
    KEY `index_mobile` (`mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='充值号码表';
/*83283*/
/*#aicall_config#*/
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
	(0, 'multi_script_text_count_limit', 10, 1, '多轮澄清轮数限制', 2),
	(0, 'csv_import_general_count_limit', 300000, 1, 'csv导入限制', 2),
	(0, 'callback_subsequent_limit', 1, 1, '回调并发量', 2);
/*83284*/
CREATE TABLE `aicall_distribute_task_rule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `task_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务id',
  `rule` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '分发规则',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  PRIMARY KEY (`id`),
  KEY `index_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='任务分发任务id与规则关联表';
/*83285*/
ALTER TABLE `aicall_mix_tts_order` ADD COLUMN `resume_point` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '打断类型 0 默认关闭 1 打断后继续播放';
/*83863*/
UPDATE `aicall_auth_rule` SET `title`='首页' WHERE `id` = 1000;
/*83864*/
DROP TABLE IF EXISTS `aicall_manual_inspection_script_node_associate`;
CREATE TABLE `aicall_manual_inspection_script_node_associate` (
    `inspection_task_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '质检任务ID',
    `script_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '话术ID',
    `script_node` varchar(255) NOT NULL DEFAULT '' COMMENT '话术节点ID',
    `script_node_name` varchar(255) NOT NULL DEFAULT '' COMMENT '话术节点名称',
    KEY `index_inspection_task_id` (`inspection_task_id`) USING BTREE,
    KEY `index_script_node` (`script_node`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='人工质检任务&话术节点关联表';
ALTER TABLE `aicall_train_task_action` ADD COLUMN `title` varchar(255) NOT NULL DEFAULT '' COMMENT '资源名称（防止资源删除找不到）';
/*84073*/
CREATE TABLE `aicall_manual_policy` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业ID',
  `field_ids` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '变量id可选范围 json格式变量id集合',
  `name` varchar(200) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '转人工策略名称',
  `default_manual_id` varchar(30) NOT NULL DEFAULT '' COMMENT '默认转人工id',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='转人工策略表';

CREATE TABLE `aicall_manual_policy_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业ID',
  `manual_policy_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '转人工策略表id',
  `value` varchar(2048) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '实际多个变量并且关系json格式数据',
  `manual_id` varchar(30) NOT NULL DEFAULT '' COMMENT '转人工id',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='转人工策略详情表';

/*#aicall_auth_action#aicall_auth_rule#aicall_auth_access#aicall_auth_rule_action#aicall_config#*/
INSERT INTO `aicall_auth_rule` (`id`, `status`, `parent_id`, `order`, `type`, `name`, `param`, `title`, `condition`, `is_show`, `nav_icon`, `allow_auth`)
VALUES
(15000, 1, 0, 50, '', 'module_knowledge_all', '', '知识库', '', 0, '', 1),
(16000, 1, 0, 60, '', 'module_crm', '', '客户管理', '', 0, '', 1),
(17000, 1, 0, 100, '', 'module_system', '', '系统管理', '', 0, '', 0),
(1010, 1, 1000, 10, '', 'statistics_call', '', '外呼统计', '', 0, '', 1),
(1020, 1, 1000, 20, '', 'statistics_script', '', '话术分析', '', 0, '', 1),
(1021, 1, 1020, 30, '', 'statistics_script_view', '', '数据浏览', '', 0, '', 1),
(1022, 1, 1020, 30, '', 'statistics_script_export_hangup', '', '导出节点挂断率', '', 0, '', 1),
(1023, 1, 1020, 30, '', 'statistics_script_export_emotion_change', '', '导出节点情緒变化', '', 0, '', 1),
(1024, 1, 1020, 30, '', 'statistics_script_export_emotion', '', '导出节点情緒', '', 0, '', 1),
(16010, 1, 16000, 30, '', 'module_manual', '', '转人工策略', '', 0, '', 1),
(16011, 1, 16010, 10, '', 'manual_view', '', '策略浏览', '', 0, '', 1),
(16012, 1, 16010, 20, '', 'manual_edit', '', '策略编辑', '', 0, '', 1),
(16013, 1, 16010, 30, '', 'manual_del', '', '策略删除', '', 0, '', 1),
(16014, 1, 16010, 40, '', 'manual_add', '', '策略新建', '', 0, '', 1),
(2018, 1, 2010, 60, '', 'script_online_offline', '', '话术上下线', '', 0, '', 1),
(2019, 1, 2010, 70, '', 'script_trycall', '', '话术试呼', '', 0, '', 1);

UPDATE `aicall_auth_rule` SET `order` = 20 WHERE `id` = 4000;
UPDATE `aicall_auth_rule` SET `order` = 25 WHERE `id` = 8000;
UPDATE `aicall_auth_rule` SET `order` = 30 WHERE `id` = 14000;
UPDATE `aicall_auth_rule` SET `order` = 40 WHERE `id` = 2000;
UPDATE `aicall_auth_rule` SET `order` = 50 WHERE `id` = 12000;
UPDATE `aicall_auth_rule` SET `order` = 70 WHERE `id` = 7000;
UPDATE `aicall_auth_rule` SET `order` = 80 WHERE `id` = 11000;
UPDATE `aicall_auth_rule` SET `order` = 90 WHERE `id` = 13000;
UPDATE `aicall_auth_rule` SET `order` = 10,`parent_id`=15000,`title`='聚类管理', `name`='module_clusters' WHERE `id` = 2020;
UPDATE `aicall_auth_rule` SET `order` = 20,`parent_id`=15000,`title`='问题库', `name`='module_question' WHERE `id` = 3000;
UPDATE `aicall_auth_rule` SET `order` = 30,`parent_id`=15000,`title`='通用知识库', `name`='module_knowledge' WHERE `id` = 12000;
UPDATE `aicall_auth_rule` SET `order` = 40,`parent_id`=15000,`name`='短信管理', `name`='module_messages' WHERE `id` = 2050;
UPDATE `aicall_auth_rule` SET `order` = 10 WHERE `id` = 9000;
UPDATE `aicall_auth_rule` SET `order` = 20 WHERE `id` = 14001;
UPDATE `aicall_auth_rule` SET `parent_id` = 1010 WHERE `id` = 1001;
UPDATE `aicall_auth_rule` SET `parent_id` = 1010 WHERE `id` = 1002;
UPDATE `aicall_auth_rule` SET `parent_id` = 1010 WHERE `id` = 1003;
UPDATE `aicall_auth_rule` SET `order` = 10,`parent_id`=16000,`title`='变量管理', `name`='module_fields' WHERE `id` = 2030;
UPDATE `aicall_auth_rule` SET `order` = 20,`parent_id`=16000,`title`='标签管理', `name`='module_labels' WHERE `id` = 2040;
UPDATE `aicall_auth_rule` SET `order` = 10,`parent_id`=17000,`title`='机器人管理', `name`='module_robot' WHERE `id` = 10000;
UPDATE `aicall_auth_rule` SET `order` = 20,`parent_id`=17000,`title`='权限管理', `name`='module_authority' WHERE `id` = 5000;
UPDATE `aicall_auth_rule` SET `order` = 30,`parent_id`=17000,`title`='操作日志', `name`='module_log' WHERE `id` = 6000;

INSERT INTO `aicall_auth_access` (`role_id`, `auth_rule_id`)
VALUES
(2, 15000),
(2, 16000),
(2, 17000),
(2, 1010),
(2, 1020),
(2, 1021),
(2, 1022),
(2, 1023),
(2, 1024),
(2, 16010),
(2, 16011),
(2, 16012),
(2, 16013),
(2, 16014),
(2, 2018),
(2, 2019);

INSERT INTO `aicall_auth_rule_action` (`rule_id`, `action_id`)
VALUES
(2012, 304),
(2012, 302),
(2012, 300),
(2012, 303),
(2012, 301),
(2012, 1),
(2012, 5),
(2012, 131),
(2012, 306),
(2012, 307),
(2012, 305),
(2012, 309),
(2012, 308),
(2012, 310),
(2012, 311),
(14005, 242),
(16011, 252),
(16012, 99),
(16012, 100),
(16012, 253),
(16013, 254),
(16014, 99),
(16014, 100),
(16014, 255),
(9001, 1),
(14001, 1),
(14001, 103),
(14001, 122),
(1020, 1),
(1020, 103),
(2012, 243),
(2012, 244),
(2012, 245),
(2012, 246),
(2012, 247),
(2012, 248),
(2012, 249),
(2018, 250),
(2018, 251),
(2019, 227),
(2019, 120),
(14002, 102),
(14005, 171),
(14005, 242);

truncate table aicall_auth_action;

INSERT INTO `aicall_auth_action` (`id`, `status`, `type`, `name`, `param`, `title`, `is_log`, `template`, `model`)
VALUES
	(1, 1, '', '/aicall/script/getScriptsByPageParams', '', '话术列表', 0, '', ''),
	(2, 1, '', '/aicall/question/exportQuestionByTypeAndData', '', '问题导出', 1, '导出-问题-批量', 'module_knowledge_all'),
	(3, 1, '', '/aicall/enterprise/importData:type=1', '', '导入聚类', 1, '导入-聚类-批量', 'module_knowledge_all'),
	(5, 1, '', '/aicall/question/getQuestionById', '', '问题详情查看', 0, '', ''),
	(96, 1, '', '/aicall/file/uploadAudioFile', '', '上传录音', 0, '', ''),
	(97, 1, '', '/aicall/file/getAudioFileById', '', '试听', 0, '', ''),
	(98, 1, '', '/aicall/script/setMixTtsDataListByJson', '', '设置mix_id', 0, '', ''),
	(99, 1, '', '/aicall/script/getFieldsByPageParams', '', '变量列表', 0, '', ''),
	(100, 1, '', '/aicall/enterprise/getGroups', '', '获取人工坐席列表', 0, '', ''),
	(101, 1, '', '/aicall/script/getMessagesByPageParams', '', '短信列表', 0, '', ''),
	(102, 1, '', '/aicall/script/getScriptContentDetailById', '', '话术详情', 0, '', ''),
	(103, 1, '', '/aicall/task/getTasks', '', '任务列表', 0, '', ''),
	(117, 1, '', '/aicall/task/getGlobalKeywordByTaskId', '', '获取全语境关键词', 0, '', ''),
	(118, 1, '', '/aicall/task/getTaskStatistics', '', '任务统计结果', 0, '', ''),
	(119, 1, '', '/aicall/task/getTaskCluesByTaskId:!export', '', '客户线索', 0, '', ''),
	(120, 1, '', '/aicall/task/getRecord', '', '通话详情', 0, '', ''),
	(121, 1, '', '/aicall/task/getRecordUrl', '', '获取通话记录试听地址', 0, '', ''),
	(122, 1, '', '/aicall/script/getLabelsByPageParams', '', '标签列表', 0, '', ''),
	(123, 1, '', '/aicall/task/deleteTasks', '', '删除任务', 1, '删除-任务-${log}', 'module_task'),
	(124, 1, '', '/aicall/task/deleteRecords', '', '删除线索', 1, '删除-通话记录-${log}', 'module_task'),
	(125, 1, '', '/aicall/enterprise/getAccountCount', '', '获取外呼机器人', 0, '', ''),
	(126, 1, '', '/aicall/enterprise/getCallNumbers', '', '获取外呼号码', 0, '', ''),
	(127, 1, '', '/aicall/task/checkFile', '', '任务校验', 0, '', ''),
	(128, 1, '', '/aicall/task/saveTask:id', '', '编辑任务', 1, '编辑-任务-${task_name}-${log}', 'module_task'),
	(129, 1, '', '/aicall/enterprise/getGlobalStatistics', '', '查看数据统计', 0, '', ''),
	(130, 1, '', '/aicall/enterprise/getStatisticsReport', '', '数据统计导出报表', 1, '导出-报表', 'module_statistics'),
	(131, 1, '', '/aicall/question/getQuestionsByWhere', '', '问题列表', 0, '', ''),
	(132, 1, '', '/aicall/script/getClustersByPageParams', '', '聚类列表', 0, '', ''),
	(133, 1, '', '/aicall/script/deleteScriptById', '', '删除话术', 1, '删除-话术-${log}', 'module_talk'),
	(134, 1, '', '/aicall/script/deleteClusterByIds', '', '删除聚类', 1, '删除-聚类-${log}', 'module_knowledge_all'),
	(135, 1, '', '/aicall/script/deleteFieldById', '', '删除变量', 1, '删除-变量-${log}', 'module_crm'),
	(136, 1, '', '/aicall/script/deleteLabelByIds', '', '删除标签', 1, '删除-标签-${log}', 'module_crm'),
	(137, 1, '', '/aicall/script/deleteMessageById', '', '删除短信', 1, '删除-短信-${log}', 'module_knowledge_all'),
	(138, 1, '', '/aicall/script/setScriptByData:!id', '', '新建话术', 1, '新增-话术-${title}', 'module_talk'),
	(139, 1, '', '/aicall/script/setClusterByData:!id', '', '新建聚类', 1, '新增-聚类-${title}', 'module_knowledge_all'),
	(140, 1, '', '/aicall/script/setFieldByData:!id', '', '新建变量', 1, '新增-变量-${title}', 'module_crm'),
	(141, 1, '', '/aicall/script/setLabelByData:!id', '', '新建标签', 1, '新增-标签-${title}', 'module_crm'),
	(142, 1, '', '/aicall/script/setMessageByData:!id', '', '新建短信', 1, '新增-短信-${title}', 'module_knowledge_all'),
	(143, 1, '', '/aicall/script/exportScriptRelateByTypeAndData:method=3', '', '导出聚类', 1, '导出-聚类-批量', 'module_knowledge_all'),
	(144, 1, '', '/aicall/question/deleteQuestionsByIds', '', '删除问题', 1, '删除-问题-${log}', 'module_knowledge_all'),
	(145, 1, '', '/aicall/task/controlTask:operate=start', '', '任务开始', 1, '开始-任务-${log}', 'module_task'),
	(146, 1, '', '/aicall/task/recallByType', '', '重呼', 1, '重呼-任务-${log}', 'module_task'),
	(147, 1, '', '/aicall/script/setClusterByData:id', '', '编辑聚类', 1, '编辑-聚类-${title}', 'module_knowledge_all'),
	(148, 1, '', '/aicall/script/setFieldByData:id', '', '编辑变量', 1, '编辑-变量-${title}', 'module_crm'),
	(149, 1, '', '/aicall/script/setLabelByData:id', '', '编辑标签', 1, '编辑-标签-${title}', 'module_crm'),
	(150, 1, '', '/aicall/script/setMessageByData:id', '', '编辑短信', 1, '编辑-短信-${title}', 'module_knowledge_all'),
	(151, 1, '', '/aicall/script/setScriptByData:id', '', '编辑话术', 1, '编辑-话术-${title}-${log}', 'module_talk'),
	(152, 1, '', '/aicall/question/setQuestionByData:id', '', '编辑问题', 1, '编辑-问题-${standard}-${log}', 'module_knowledge_all'),
	(153, 1, '', '/aicall/question/setQuestionByData:!id', '', '新建问题', 1, '新增-问题-${standard}', 'module_knowledge_all'),
	(154, 1, '', '/aicall/task/saveTask:!id', '', '新建任务', 1, '新增-任务-${task_name}', 'module_task'),
	(155, 1, '', '/aicall/enterprise/importData:type=2', '', '导入问题', 1, '导入-问题-批量', 'module_knowledge_all'),
	(156, 1, '', '/aicall/enterprise/importData:type=3', '', '导入标签', 1, '导入-标签-批量', 'module_crm'),
	(157, 1, '', '/aicall/enterprise/importData:type=4', '', '导入变量', 1, '', 'module_crm'),
	(158, 1, '', '/aicall/script/exportScriptRelateByTypeAndData:method=5', '', '导出标签', 1, '导出-标签-批量', 'module_crm'),
	(159, 1, '', '/aicall/script/exportScriptRelateByTypeAndData:method=6', '', '导出变量', 1, '导出-变量-批量', 'module_crm'),
	(161, 1, '', '/aicall/enterprise/getFreeAccount', '', '获取空闲机器人数', 0, '', ''),
	(162, 1, '', '/aicall/authority/getAuthority', '', '获取权限树', 0, '', ''),
	(163, 1, '', '/aicall/authority/getRolesByWhere', '', '获取角色列表', 0, '', ''),
	(164, 1, '', '/aicall/authority/getRoleById', '', '获取角色详情', 0, '', ''),
	(165, 1, '', '/aicall/authority/setRoleByData:!id', '', '新建角色', 1, '新增-角色-${name}', 'module_system'),
	(166, 1, '', '/aicall/authority/setRoleByData:id', '', '编辑角色', 1, '编辑-角色-${name}', 'module_system'),
	(167, 1, '', '/aicall/authority/deleteRolesByIds', '', '删除角色', 1, '删除-角色-${log}', 'module_system'),
	(168, 1, '', '/aicall/authority/controlRolesByIds:status=1', '', '启用角色', 1, '启用-角色-${log}', 'module_system'),
	(169, 1, '', '/aicall/authority/setUserByData:!id', '', '新建账户', 1, '新增-账户-${username}', 'module_system'),
	(170, 1, '', '/aicall/authority/setUserByData:id', '', '编辑账户', 1, '编辑-账号-${username}', 'module_system'),
	(171, 1, '', '/aicall/authority/getUsersByWhere', '', '获取账户列表', 0, '', ''),
	(172, 1, '', '/aicall/authority/resetPasswordById', '', '重置密码', 1, '', 'module_system'),
	(173, 1, '', '/aicall/authority/deleteUsersByIds', '', '删除账户', 1, '删除-账户-${log}', 'module_system'),
	(174, 0, '', '/aicall/identity/login', '', '登录', 1, '', 'login'),
	(175, 1, '', '/aicall/task/getRecordsByTaskId:export=1', '', '导出任务通话记录', 1, '外呼-导出通话记录', 'module_task'),
	(176, 1, '', '/aicall/task/getRecordsByTaskId:export=2', '', '导出任务通话文本', 1, '外呼-导出通话文本', 'module_task'),
	(177, 1, '', '/aicall/task/controlTask:operate=pause', '', '任务暂停', 1, '暂停-任务-${log}', 'module_task'),
	(178, 1, '', '/aicall/authority/controlRolesByIds:status=0', '', '禁用角色', 1, '禁用-角色-${log}', 'module_system'),
    (179, 0, '', '/aicall/identity/loginByMobile', '', '短信登录', 1, '短信登录', 'login'),
    (180, 1, '', '/aicall/task/recall', '', '重呼', 1, '重呼-任务-${log}', 'module_task'),
    (181, 1, '', '/aicall/blacklist/setBlackCluesByData', '', '新增黑名单', 1, '新增-黑名单-手动添加', 'module_blackst'),
    (182, 1, '', '/aicall/blacklist/delBlackCluesById', '', '删除黑名单', 1, '删除-黑名单-${log}', 'module_blackst'),
    (183, 1, '', '/aicall/enterprise/importData:type=5', '', '导入黑名单', 1, '导入-黑名单-批量导入', 'module_blackst'),
    (184, 1, '', '/aicall/blacklist/getBlackClueByMobile', '', '查询黑名单', 0, '', ''),
    (185, 1, '', '/aicall/statistic/exportNumber', '', '导出号码清单', 1, '导出-号码清单', 'module_statistics'),
    (186, 1, '', '/aicall/script/importScriptByData', '', '话术导入', 1, '导入-话术', 'module_talk'),
    (187, 1, '', '/aicall/script/exportScriptByData', '', '话术导出', 1, '导出-话术', 'module_talk'),
    (188, 1, '', '/aicall/task/getRecordsByTaskId:export=4', '', '导出反馈结果', 1, '导出-反馈结果', 'module_task'),
    (189, 1, '', '/aicall/task/exportRecordAudios', '', '录音批量导出', 1, '外呼-录音批量导出', 'module_task'),
    (190, 1, '', '/aicall/task/getRecordsByTaskId:!export', '', '任务详情查看', 0, '查看-任务详情', ''),
    (191, 1, '', '/aicall/highRisk/getHighRiskCustomerByPageParams:!export', '', '获取高风险清单列表', 0, '查看高风险清单', ''),
    (192, 1, '', '/aicall/highRisk/updateStatusByIds', '', '处理高风险清单状态', 1, '处理高风险清单状态', 'module_highrisk'),
    (193, 1, '', '/aicall/highRisk/getHighRiskCustomerByPageParams:export=1', '', '高风险清单导出', 1, '高风险清单导出', 'module_highrisk'),
    (194, 1, '', '/aicall/incall/setIncallScript', '', '呼入设置', 1, '呼入设置', 'module_talk'),
    (195, 1, '', '/aicall/incall/search', '', '获取呼入记录列表', 0, '查看呼入记录', ''),
    (196, 1, '', '/aicall/incall/exportRecords', '', '导出通话记录', 1, '呼入-导出通话记录', 'module_callin'),
    (197, 1, '', '/aicall/incall/exportRecordContents', '', '导出通话文本', 1, '呼入-导出通话文本', 'module_callin'),
    (198, 1, '', '/aicall/incall/exportRecordAudios', '', '录音批量导出', 1, '呼入-录音批量导出', 'module_callin'),
    (199, 1, '', '/aicall/highRisk/createHighRiskScanRuleByJson', '', '设置高风险规则', 1, '设置高风险规则', 'module_highrisk'),
    (200, 1, '', '/aicall/highRisk/deleteHighRiskScanRuleByJson', '', '设置高风险规则', 1, '设置高风险规则', 'module_highrisk'),
    (201, 1, '', '/aicall/enterprise/setConfig:intelligent_inspection_rule', '', '设置高风险规则', 1, '设置高风险规则', 'module_highrisk'),
    (202, 1, '', '/aicall/task/changeTaskEnterprise', '', '任务迁移', 1, '任务迁移', 'module_task'),
    (203, 1, '', '/aicall/task/getSpeechFile', '', '话术说明', 0, '话术说明', ''),
    (204, 1, '', '/aicall/enterprise/getLicenseDetail', '', '机器人详情', 0, '查看-机器人管理列表', ''),
    (205, 1, '', '/aicall/enterprise/importLicense', '', '上传license', 1, '上传license文件${log}', 'module_system'),
    (206, 1, '', '/aicall/task/getRecordUrl:operate=1', '', '下载录音', 0, '下载录音', ''),
    (207, 1, '', '/aicall/task/getRecordUrl:operate=0', '', '试听录音', 0, '试听录音', ''),
    (208, 1, '', '/aicall/script/pushScript', '', '话术推送', 1, '${log}', 'module_talk'),
    (209, 1, '', '/aicall/department/getDepartmentList', '', '查看部门列表', 0, '查看部门列表', ''),
    (210, 1, '', '/aicall/department/setDepartment:!department_id', '', '新建部门', 1, '新建部门“${name}”', 'module_system'),
    (211, 1, '', '/aicall/department/setDepartment:department_id', '', '编辑部门', 1, '编辑部门“${name}”', 'module_system'),
    (212, 1, '', '/aicall/department/deleteDepartment', '', '删除部门', 1, '删除部门“${log}”', 'module_system'),
    (213, 1, '', '/aicall/enterprise/getApiKey', '', '查看API管理内容', 0, '查看API管理内容', ''),
    (214, 1, '', '/aicall/enterprise/setConfig', '', '编辑回调地址', 1, '编辑回调地址“${api_callback_domain}”', 'module_api'),
    (215, 1, '', '/aicall/enterprise/deleteIpFromWhiteList', '', '编辑白名单', 1, '编辑白名单', 'module_api'),
    (216, 1, '', '/aicall/enterprise/setIpWhiteListByIp', '', '编辑白名单', 1, '编辑白名单', 'module_api'),
    (217, 1, '', '/aicall/task/getTaskCluesByTaskId:export=1', '', '客户线索导出', 1, '', 'module_task'),
    (218, 1, '', '/aicall/blacklist/export', '', '黑名单导出', 1, '黑名单导出', 'module_blackst'),
    (219, 1, '', '/aicall/highRisk/updateBlackStatusByIds', '', '高风险新增黑名单', 1, '质检号码加入黑名单', 'module_knowledge_all'),
    (220, 1, '', '/aicall/script/setPriorityByData', '', '优先级设置', 1, '${log}', 'module_talk'),
    (221, 1, '', '/aicall/enterprise/getUpdateKnowledgeLibrary', '', '查看知识库列表', 0, '查看“知识库列表”', ''),
    (222, 1, '', '/aicall/enterprise/getUpdateResourceDetail', '', '查看知识库详情', 0, '查看“知识库详情”', ''),
    (223, 1, '', '/aicall/enterprise/syncUpdate:resource_type=1', '', '更新聚类', 1, '更新聚类${log}', 'module_knowledge_all'),
    (224, 1, '', '/aicall/enterprise/syncUpdate:resource_type=2', '', '更新问题', 1, '更新问题${log}', 'module_knowledge_all'),
    (225, 1, '', '/aicall/enterprise/ignoreUpdateByIds:resource_type=1', '', '忽略聚类', 1, '忽略聚类${log}', 'module_knowledge_all'),
    (226, 1, '', '/aicall/enterprise/ignoreUpdateByIds:resource_type=2', '', '忽略问题', 1, '忽略问题${log}', 'module_knowledge_all'),
    (227, 1, '', '/aicall/script/tryCall', '', '话术试呼', 1, '${log}', 'module_talk'),
    (228, 1, '', '/aicall/incall/getRecordAudioUrl:operate=0', '', '试听录音', 0, '试听录音', ''),
    (229, 1, '', '/aicall/incall/getRecordAudioUrl:operate=1', '', '下载录音', 0, '下载录音', ''),
    (230, 1, '', '/aicall/incall/getRecord', '', '通话详情', 0, '查看通话详情', ''),
    (231, 1, '', '/aicall/highRisk/getRecord', '', '通话详情', 0, '查看通话详情', ''),
    (232, 1, '', '/aicall/enterprise/getPushSmsConfig', '', '企业微信设置', 1, '企业微信设置', 'module_api'),
    (233, 1, '', '/aicall/ManualInspection/getTaskList', '', '质检任务浏览', 0, '质检任务浏览', ''),
    (234, 1, '', '/aicall/ManualInspection/createTask', '', '新建质检任务', 1, '新建-质检任务-${name}-${log}', 'module_highrisk'),
    (235, 1, '', '/aicall/ManualInspection/modifyTask', '', '编辑质检任务', 1, '编辑-质检任务-${name}-${log}', 'module_highrisk'),
    (236, 1, '', '/aicall/ManualInspection/deleteTask', '', '删除质检任务', 1, '删除-质检任务-${log}', 'module_highrisk'),
    (237, 1, '', '/aicall/ManualInspection/changeDialogStatusByIds', '', '更新质检状态', 1, '更新质检状态', 'module_highrisk'),
    (238, 1, '', '/aicall/ManualInspection/saveDialogInspectionDetails', '', '修改意图', 1, '修改意图', 'module_highrisk'),
    (239, 1, '', '/aicall/ManualInspection/getRecord', '', '通话详情', 0, '查看通话详情', ''),
    (240, 1, '', '/aicall/ManualInspection/getRecordUrl:operate=1', '', '下载录音', 0, '下载录音', ''),
    (241, 1, '', '/aicall/ManualInspection/getRecordUrl:operate=0', '', '试听录音', 0, '试听录音', ''),
    (242, 1, '', '/aicall/ManualInspection/getTaskDetailInfo', '', '质检详情', 0, '质检详情', ''),
    (243, 1, '', '/aicall/train/getTrainTaskList', '', '训练任务浏览', 0, '查看“训练任务列表”', ''),
    (244, 1, '', '/aicall/train/getTrainTaskSourceDetail', '', '训练任务详情页浏览', 0, '查看“训练详情”', ''),
    (245, 1, '', '/aicall/train/operateTrainTask:operate_type=1', '', '开始训练', 1, '启动-${name}', 'module_talk'),
    (246, 1, '', '/aicall/train/operateTrainTask:operate_type=2', '', '发布训练任务', 1, '发布-${name}', 'module_talk'),
    (247, 1, '', '/aicall/train/operateTrainTask:operate_type=3', '', '回退训练任务', 1, '回退-${name}', 'module_talk'),
    (248, 1, '', '/aicall/train/operateTrainTask:operate_type=4', '', '验证拉起服务', 1, '验证-${name}', 'module_talk'),
    (249, 1, '', '/aicall/train/operateTrainTask:operate_type=5', '', '验证通过', 1, '验证通过-${name}', 'module_talk'),
    (250, 1, '', '/aicall/script/setScriptOnlineAndOffline:type=1', '', '话术上线', 1, '上线话术-${name}', 'module_talk'),
    (251, 1, '', '/aicall/script/setScriptOnlineAndOffline:type=2', '', '话术下线', 1, '下线话术-${name}', 'module_talk'),
    (252, 1, '', '/aicall/policy/getManualPolicyDetail', '', '转人工策略详情', 0, '查看转人工策略-${name}', ''),
    (253, 1, '', '/aicall/policy/setManualPolicyByData:policy_id', '', '编辑转人工策略', 1, '编辑转人工策略-${name}', 'module_crm'),
    (254, 1, '', '/aicall/policy/deleteManualPolicyById', '', '删除转人工策略', 1, '删除转人工策略-${name}', 'module_crm'),
    (255, 1, '', '/aicall/policy/setManualPolicyByData:!policy_id', '', '新增转人工策略', 1, '新增转人工策略-${name}', 'module_crm'),

    (300, 1, '', '/aicall/script/setClusterByData:!id&source=1', '', '新建聚类', 1, '新增-聚类-${title}', 'module_talk'),
    (301, 1, '', '/aicall/script/setClusterByData:id&source=1', '', '编辑聚类', 1, '编辑-聚类-${title}', 'module_talk'),
    (302, 1, '', '/aicall/script/deleteClusterByIds:source=1', '', '删除聚类', 1, '删除-聚类-${log}', 'module_talk'),
    (303, 1, '', '/aicall/script/exportScriptRelateByTypeAndData:method=3&source=1', '', '导出聚类', 1, '导出-聚类-批量', 'module_talk'),
    (304, 1, '', '/aicall/enterprise/importData:type=1&source=1', '', '导入聚类', 1, '导入-聚类-批量', 'module_talk'),
    (305, 1, '', '/aicall/question/setQuestionByData:!id&source=1', '', '新建问题', 1, '新增-问题-${standard}', 'module_talk'),
    (306, 1, '', '/aicall/question/setQuestionByData:id&source=1', '', '编辑问题', 1, '编辑-问题-${standard}-${log}', 'module_talk'),
    (307, 1, '', '/aicall/question/deleteQuestionsByIds:source=1', '', '删除问题', 1, '删除-问题-${log}', 'module_talk'),
    (308, 1, '', '/aicall/question/exportQuestionByTypeAndData:source=1', '', '问题导出', 1, '导出-问题-批量', 'module_talk'),
    (309, 1, '', '/aicall/enterprise/importData:type=2&source=1', '', '导入问题', 1, '导入-问题-批量', 'module_talk'),
    (310, 1, '', '/aicall/question/copyQuestions', '', '复制问题', 1, '复制-问题-${log}', 'module_talk'),
    (311, 1, '', '/aicall/script/copyClusters', '', '复制聚类', 1, '复制-聚类-${log}', 'module_talk');

ALTER TABLE aicall_log ADD INDEX index_garden(`garden`);

UPDATE `aicall_log` SET `garden` = 'module_callin' WHERE `garden` = 'in_call';
UPDATE `aicall_log` SET `garden` = 'module_talk' WHERE `garden` = 'script';
UPDATE `aicall_log` SET `garden` = 'module_statistics' WHERE `garden` = 'statistic';
UPDATE `aicall_log` SET `garden` = 'module_knowledge_all' WHERE `garden` = 'question';
UPDATE `aicall_log` SET `garden` = 'module_system' WHERE `garden` = 'authority';
UPDATE `aicall_log` SET `garden` = 'module_task' WHERE `garden` = 'task';
UPDATE `aicall_log` SET `garden` = 'module_blackst' WHERE `garden` = 'blacklist';
UPDATE `aicall_log` SET `garden` = 'module_highrisk' WHERE `garden` = 'high_risk';
UPDATE `aicall_log` SET `garden` = 'module_knowledge_all' WHERE `garden` = 'knowledge';
UPDATE `aicall_log` SET `garden` = 'module_api' WHERE `garden` = 'api';
UPDATE `aicall_log` SET `garden` = 'module_api' WHERE `garden` = 'work_wechat_config';

INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
    (0, 'call_record_csv_export_count_limit', 1000000, 1, '通话记录导出最大数量限制', 2);
/*84205*/
ALTER TABLE `aicall_global_blacklist` ADD COLUMN `author` varchar(100) NOT NULL DEFAULT '' COMMENT '提出人';
ALTER TABLE `aicall_global_blacklist` ADD COLUMN `author_phone` varchar(100) NOT NULL DEFAULT '' COMMENT '提出人电话';
ALTER TABLE `aicall_global_blacklist` ADD COLUMN `reason` varchar(100) NOT NULL DEFAULT '' COMMENT '备注';
ALTER TABLE `aicall_global_blacklist` ADD COLUMN `type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '类型 0默认 1客户投诉 2高危人群 3公务号码 4成单客户 5智能质检添加 6 其他原因';
UPDATE `aicall_auth_rule` SET `order` = 10 WHERE `id` = 1021;
UPDATE `aicall_auth_rule` SET `order` = 20 WHERE `id` = 1022;
UPDATE `aicall_auth_rule` SET `order` = 40 WHERE `id` = 1024;
ALTER TABLE `emergency_contacter` ADD INDEX `index_task_id` (`task_id`) USING BTREE;
/*84643*/
ALTER TABLE `question` ADD COLUMN `cluster_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '绑定聚类id';
ALTER TABLE `question` ADD INDEX `index_cluster_id` (`cluster_id`) USING BTREE;
/*85091*/
DROP TABLE IF EXISTS `aicall_realtime_clue_record`;
CREATE TABLE `aicall_realtime_clue_record`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `eid` int(10) NULL DEFAULT NULL DEFAULT '0' COMMENT '企业ID',
  `uuid` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `priority` tinyint(2) NOT NULL DEFAULT 0 COMMENT '优先级1实时，2离线，大于1离线',
  `script_id` int(10) NOT NULL DEFAULT 0 COMMENT '话术ID',
  `var_keys` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '变量信息',
  `clues` text NOT NULL COMMENT '线索信息',
  `status` tinyint(2) NOT NULL DEFAULT 0 COMMENT '该记录是否处理，0 未处理, 1 已处理',
  `create_time` int(10) NULL DEFAULT 0 COMMENT '添加时间（时间 秒）',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_create_time` (`create_time`, `eid`)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '实时线索记录表';
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
  (0,'max_task_run_count_limit', 30, 1, '可同时待开始任务最大阈值', 2),
  (0,'system_sms_forbid_control', 0, 1, '短信禁止登录开关', 3);
/*85699*/
ALTER TABLE aicall_script_analysis ADD INDEX index_eid_script_id_node_id (`eid`, `script_id`, `script_node_id`) USING BTREE;
/*86482*/
-- Table structure for aicall_script_normal_nlp_map
-- ----------------------------
DROP TABLE IF EXISTS `aicall_script_normal_nlp_map`;
CREATE TABLE `aicall_script_normal_nlp_map`(
    `id`               int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `eid`              int(10)          NOT NULL           COMMENT '企业唯一ID',
    `normal_script_id` int(10)          NOT NULL           COMMENT '普通话术ID',
    `nlp_script_id`    int(10)          NOT NULL           COMMENT 'NLP话术ID',
    `create_time`      int(10)          NOT NULL,
    PRIMARY KEY (`id`),
    KEY `index_normal_script_id` (`normal_script_id`)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '普通话术与NLP话术映射表';

-- Table structure for aicall_outcall_clue_import_failed_history
-- ----------------------------
DROP TABLE IF EXISTS `aicall_outcall_clue_import_failed_history`;
CREATE TABLE `aicall_outcall_clue_import_failed_history`(
    `id`               int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `eid`              int(10)          NOT NULL            COMMENT '企业唯一ID',
    `task_id`          int(10)          NOT NULL            COMMENT '任务ID',
    `import_type`      tinyint(2)       NOT NULL DEFAULT 1  COMMENT '导入方式：1.api导入;',
    `phone`            varchar(100)     NOT NULL DEFAULT '' COMMENT '线索号码',
    `alias`            varchar(100)     NOT NULL DEFAULT '' COMMENT '线索别名',
    `failed_reason`    varchar(100)     NOT NULL DEFAULT '' COMMENT '失败原因',
    `create_time`      int(10)          NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '线索导入失败原因记录';

ALTER TABLE `outcall_task` ADD COLUMN `is_vip` tinyint(4) NOT NULL DEFAULT 0 COMMENT '标记是否为VIP任务' AFTER `batch_number`;
/*86483*/
ALTER TABLE `aicall_outcall_clue_import_failed_history` ADD COLUMN `script_id` int(10) NOT NULL DEFAULT 0 COMMENT '话术ID';
INSERT INTO `aicall_config` (`eid`, `key`, `value`, `status`, `describe`, `type`)
VALUES
    (0,'sms_manual_send_line_number', 2, 1, '手动发送短信并发线路数量', 2);

DROP TABLE IF EXISTS `aicall_sms_manual_send_history`;
CREATE TABLE `aicall_sms_manual_send_history`(
     `id`          int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
     `history_id`  int(10)          NOT NULL DEFAULT 0 COMMENT 'aicall_sms_send_history表主键id',
     `phone`       varchar(100)     NOT NULL DEFAULT 0 COMMENT '手机号',
     `clue_id`     int(10)          NOT NULL           COMMENT 'outcall_clue表主键id',
     `batch_id`    int(10)          NOT NULL           COMMENT 'aicall_sms_manual_send_batch表主键id',
     `status`      tinyint(2)       NOT NULL DEFAULT 0 COMMENT '发送状态：0为尚未发送，1为已发送，2为发送失败，3为变量缺失不发送',
     `send_time`   int(10)          NOT NULL DEFAULT 0 COMMENT '短信发送时间',
     `create_time` int(10)          NOT NULL,
     PRIMARY KEY (`id`),
     KEY `index_clue_id` (`clue_id`),
     KEY `index_batch_id` (`batch_id`)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '手动发送短信记录表';

DROP TABLE IF EXISTS `aicall_sms_manual_send_batch`;
CREATE TABLE `aicall_sms_manual_send_batch`(
    `id`               int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `eid`              int(10)          NOT NULL           COMMENT '所属企业id',
    `task_id`          int(10)          NOT NULL           COMMENT 'outcall_task表主键id',
    `template_id`      int(10)          NOT NULL           COMMENT 'sms_template表主键id',
    `template_name`    varchar(30)      NOT NULL           COMMENT '批次生成的时候sms_template表name快照',
    `template_content` varchar(400)     NOT NULL           COMMENT '批次生成的时候sms_template表content快照',
    `create_time`      int(10)          NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '手动发送短信记录表';

ALTER TABLE `sms_template` ADD COLUMN `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '短信备注';
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
