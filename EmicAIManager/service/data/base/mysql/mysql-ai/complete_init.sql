#local ai-server 
use ai;
delete from `aicall_config` where `key`="local_tts_url_enabled";
delete from `aicall_config` where `key`="local_tts_url";
delete from `aicall_config` where `key`="db_version";
INSERT INTO `aicall_config` (`id`, `eid`, `key`, `value`, `status`, `describe`, `type`) VALUES (NULL, '0', 'local_tts_url_enabled', '1', '1', 'tts本地化', '2');
INSERT INTO `aicall_config` (`id`, `eid`, `key`, `value`, `status`, `describe`, `type`) VALUES (NULL, '0', 'local_tts_url', 'http://tts.emic:18100', '1', '本地化tts URL', '2');
INSERT INTO `aicall_config` (`id`, `eid`, `key`, `value`, `status`, `describe`, `type`) VALUES (NULL, '0', 'local_tts_url_ali', 'http://tts.emic:8101', '1', '本地化tts ali URL', '2');
update aicall_config set `value`="outcall.emic" where `key`='outcall_server_host';
INSERT INTO `aicall_tts_version` (`tts_version_code`, `tts_version_desc`, `order`, `api_version`, `tts_voice_name`, `tts_company_id`)
VALUES
    (11, '梦兰', 56, 1, 'yimiyuntong', 2);

INSERT INTO `aicall_config` (`id`, `eid`, `key`, `value`, `status`, `describe`, `type`) VALUES (NULL, '0', 'db_version', '91431', '1', '数据库版本', '2');