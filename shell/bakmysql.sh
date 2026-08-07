#!/bin/bash

bakpath=/var/pbx/backup
passwd=Sinicnet@123456
host=127.0.0.1
user=root
find $bakpath  -mtime +12  -name "*.sql" exec rm -f {} \;
mysqldump -u$user -p$passwd -h $host -P 13306 ai -R -E --single-transaction > $backpath/ai_`date +%Y%m%d`.sql

