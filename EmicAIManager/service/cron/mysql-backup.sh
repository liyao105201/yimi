#! /bin/bash
#Save sa /etc/mysql-backup.sh

BAKDIR="/var/pbx/backup"
MYSQLUSR="root"
MYSQLPW="Sinicnet@123456"
LOG=/var/pbx/backup/log/mysql-backup.log
NOW=`date +%Y-%m-%d-%H-%M`
[ ! -d $BAKDIR ] && mkdir -p $BAKDIR
[ ! -d $BAKDIR/log ] && mkdir -p $BAKDIR/log
echo "##########today##########" >>$LOG
echo "mysql bakup begin at `date`" >>$LOG

for db in exctime opms
        do
                mysqldump -u$MYSQLUSR -p$MYSQLPW -R --databases $db | gzip >  $BAKDIR/$db-$NOW.sql.gz
                if [ $? == 0 ];then
                        echo "$NOW--$db  backup succeeded!" >> $LOG
                else
                        echo "$db backup failed!" >> $LOG
                fi
        done
# 远程
# rsync -az  --delete  /data/mysql/* root@192.168.1.252:/data/backup
#if [ $? == 0 ];then
#       echo "$NOW Remote backup succeeded!" >> $LOG
#else
#       echo "$NOW Remote backup failed!" >> $LOG
#fi

find $BAKDIR -type f -mtime +60 |xargs rm -rf
#find $BAKDIR/* -mtime +10 -exec rm {} \;
echo "mysql bakup end at `date`" >>$LOG