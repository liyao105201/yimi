#!/usr/bin/bash

###log path
LOG_PATH=/data2/OutcallServer
### log back up path 
BAK_PATH=/data/outcallserver/log
### tar files existing days
SAVED_DAYS=3

echo "-----------------------"
if [ `pwd` != ${LOG_PATH} ];then
	echo "    Current path is `pwd`"
	cd ${LOG_PATH}
fi



TODAY_TAG=`date +%Y%m%d`
echo "    Today is ${TODAY_TAG}"

LATEST_DATE=`ls -stl  OutcallServer.INFO* | awk '{print $12}'| awk -F '.' '{print$6}' | awk -F '-' '{print $1}' `

echo "    Latest log date is ${LATEST_DATE}"

dat_arr=`ls -lst  OutcallServer*INFO* | awk '{print $10}' | awk -F '.' '{print$6}' | awk -F '-' '{print $1}' | sort |uniq`

echo "    Date array is: " ${dat_arr[*]}


#dat_len=${#dat_arr[*]}
#if [ ${dat_len}=="1" ];then
#    echo "    No expired log, No need to compress!"
#	echo ""
#    exit
#fi




if [ ! -d ${BAK_PATH} ];then
    echo "    Back up path ${BAK_PATH} NOT exists !!!"
	exit
else
    echo "    Back up path is ${BAK_PATH}"
	
fi

echo "-----------------------"

for dat in ${dat_arr}
do
    if [ -z ${dat} ];then
        #echo "empty ${dat}"
        continue
    fi
    if [[ ${dat} = ${TODAY_TAG} ]];then
        echo "    Log date equals today! ignored"
	elif [[ ${dat} = ${LATEST_DATE} ]];then
	    echo "    Log date equals latest log date! ignored"
    else
        # package and delete
        tar zcvf OutcallServer_${dat}.tar.gz   OutcallServer.*INFO.${dat}*
        rm -vf OutcallServer.*INFO.${dat}*
        mv OutcallServer_${dat}.tar.gz   ${BAK_PATH}
    fi
done
echo "-----------------------"
### delete expired tar.gz files
total_dat=`ls -l  ${BAK_PATH}/OutcallServer_* | wc -l`
echo "    totally ${total_dat} .tar.gz files at ${BAK_PATH}/"
### 删除超过保存时间的压缩文件
if [[ ${total_dat} -gt ${SAVED_DAYS} ]];then

	exp_num=`expr ${total_dat} - ${SAVED_DAYS}`
	
	exp_date=`ls -lrst  ${BAK_PATH}/OutcallServer_*| head  -n  ${exp_num}| awk '{print $10}' | awk -F '.' '{print$1}'`
	 
	echo "    ${exp_num} files expired:" ${exp_date[*]} 
	
	for dat in ${exp_date}
	do
		echo "    delete ${dat}.tar.gz..."
		rm -vf  ${dat}.tar.gz
	done
else
#	exp_num=`expr 7 - ${total_dat}`
#	echo "    ${exp_num}"
	echo "    No expired files .tar.gz files at ${BAK_PATH} !"
fi
echo "-----------------------"
	
