#!/bin/bash
#此脚本用来FS1-FS7注册文件重复查询   （重复会导致的机器人互踢）
set +e
path=/var/pbx/error
file1=allxml.txt
fs1_ip=172.17.214.22
fs2_ip=172.17.214.31
fs3_ip=172.17.214.43
fs4_ip=172.17.214.44
fs5_ip=172.17.214.49
fs6_ip=172.17.253.81
fs7_ip=172.17.214.64
fs1_pw='$OFc8vIIp0Rk^wKJ'
fs2_pw='Tjtk7a%89lr%CsaG'
fs3_pw='yO0SgeA%a1bEQ$Up'
fs4_pw='W%d0bkxZxZLf3i$9'
fs5_pw='FLg#qSQBal$QeJS4'
fs6_pw='s*DMGyzI%rRP%t7k'
fs7_pw='0lhJ4uaSx2u4Ca!7'
#远程执行命令产生文件
cat << EOF
+-------------------------------------+
   文件路径$path
+-------------------------------------+
EOF
sleep 3
cat << EOF
+-------------------------------------+
   正在统计注册数据
+-------------------------------------+
EOF
sleep 3
files=("FS2.TXT" "FS3.TXT" "FS4.TXT" "FS5.TXT" "FS6.TXT" "FS7.TXT")
files_output=("output_FS2.TXT" "output_FS3.TXT" "output_FS4.TXT" "output_FS5.TXT" "output_FS6.TXT" "output_FS7.TXT" )
cd $path
fs_cli -H localhost -P 8011 -p Emicnet2019 -x 'sofia status'|awk '{print $1}'|awk  -F':' '{print $3}'>FS1.TXT
sshpass -p ${fs2_pw} ssh  root@${fs2_ip}   "fs_cli -H localhost -P 8011 -p Emicnet123456 -x 'sofia status'>FS2.TXT"
echo "正在统计FS2"
sshpass -p ${fs2_pw}  scp root@${fs2_ip}:/root/FS2.TXT ./
sshpass -p ${fs3_pw} ssh  root@${fs3_ip}   "docker exec freeswitch bash -c \"fs_cli -H localhost -P 8011 -p Emicnet123456 -x 'sofia status' > FS3.TXT\";docker cp freeswitch:/FS3.TXT /var"
echo "正在统计FS3"
sshpass -p ${fs3_pw} scp root@${fs3_ip}:/var/FS3.TXT ./
sshpass -p ${fs4_pw} ssh  root@${fs4_ip}   "docker exec freeswitch bash -c \"fs_cli -H localhost -P 8011 -p Emicnet123456 -x 'sofia status' > FS4.TXT\";docker cp freeswitch:/FS4.TXT /var"
sshpass -p ${fs4_pw}  scp root@${fs4_ip}:/var/FS4.TXT ./
echo "正在统计FS4"
sshpass -p "${fs5_pw}" ssh root@${fs5_ip} "docker exec freeswitch bash -c 'fs_cli -H localhost -P 8011 -p Emicnet123456 -x \"sofia status\" > FS5.TXT';docker cp freeswitch:/FS5.TXT /var"
sshpass -p "${fs5_pw}"  scp root@${fs5_ip}:/var/FS5.TXT ./
echo "正在统计FS5"
sshpass -p ${fs6_pw} ssh  root@${fs6_ip}   "docker exec freeswitch bash -c \"fs_cli -H localhost -P 8011 -p Emicnet123456 -x 'sofia status' > FS6.TXT\";docker cp freeswitch:/FS6.TXT /var"
sshpass -p ${fs6_pw}  scp  root@${fs6_ip}:/var/FS6.TXT ./
echo "正在统计FS6"
sshpass -p ${fs7_pw} ssh -p 20044 root@${fs7_ip}   "docker exec freeswitch bash -c \"fs_cli -H localhost -P 8011 -p Emicnet123456 -x 'sofia status'  > FS7.TXT\";docker cp freeswitch:/FS7.TXT /var"
echo "正在统计FS7"
sshpass -p ${fs7_pw}  scp -P 20044 root@${fs7_ip}:/var/FS7.TXT ./
sed -i '/^$/d' FS1.TXT
for file in "${files[@]}"
do  
    cat $file|awk '{print $1}'|awk  -F':' '{print $3}'>${file}_bak && mv ${file}_bak $file
    sed -i '/^$/d' $file
    # 创建输出文件名
    output_file="output_${file}"
    # 对比文件并输出匹配的行到输出文件
    grep -F -f "$file" "FS1.TXT" > "$output_file"
    sed -i '/examp/d' $output_file
    echo "重复数据文件${output_file}产生"
    rm $file -f
done
echo "正在进行重复数据数据库相应查询"
for file in "${files_output[@]}"
do
    sed -i '/^[^a-zA-Z]/d' $file
    for line in `cat $file`
        do
          data=`mysql -uemi_ai  -pSinicnet123456 -h'172.17.214.23' -e 'use ai;SELECT id,name,switch_number from enterprise_info where id=(SELECT  DISTINCT  enterprise_uid from account where username="'$line'")'`
          echo "$data">info.txt
          cat info.txt|awk 'NR>1'>>error_enterprise.txt 
        done
    rm $file -f
done
#排序去重并删除
rm info.txt -f
sort error_enterprise.txt|uniq >error_info.txt
rm error_enterprise.txt
rm FS1.TXT -f
