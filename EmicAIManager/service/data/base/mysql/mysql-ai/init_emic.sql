ALTER USER 'root'@'localhost' IDENTIFIED BY 'Sinicnet@123456';
SET GLOBAL group_concat_max_len=102400000;
SET SESSION group_concat_max_len=102400000;
create user 'emi_ai'@'%' identified by 'Sinicnet@123456';
grant all privileges on *.* to 'emi_ai'@'%' identified by 'Sinicnet@123456' with grant option;
create user 'emi_web'@'%' identified by 'Sinicnet@123456';
grant all privileges on *.* to 'emi_web'@'%' identified by 'Sinicnet@123456' with grant option;
flush privileges;
create database `ai`;

create user 'cheryfs_cn'@'localhost' identified by 'TAwHMM2VuQJB3QhP';
grant all privileges on *.* to 'cheryfs_cn'@'localhost' identified by 'TAwHMM2VuQJB3QhP' with grant option;