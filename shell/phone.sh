#!/bin/bash
#写入号码
#删除第一行汉语字符,去除csv的回车符,^M等于\r
sed -i '1d' 20210719.csv
sed -i 's/\r//g' 20210719.csv
number=`sort 20210719.csv |uniq|wc -w`
nums=`cat 20210719.csv|tr -d '\r'`
function show_nums() {
cat << EOF
+-------------------------------------------------+
                  准备写入号码

                  号码总个数：" $number "
      -----------------------------------------
+-------------------------------------------------+
EOF
}
show_nums
sleep 3.5
for phone in $nums 
do
  command="redis-cli -a greeisgood -p 16379"
  afphone=`echo $phone|tr -d '\r\n'`
  command1="$command set oc_1_answered_$afphone 1"
  command2="$command EXPIRE oc_1_answered_$afphone 2678400"
  command3="$command sadd oc_calling_set_1 $afphone "
  eval $command1 &>/dev/null
  eval $command2 &>/dev/null
  eval $command3 &>/dev/null
  echo "号码写入中:$phone"
done
  command4="$command scard oc_calling_set_1"
  allnumber=`eval $command4`
function show_nums1() {
cat << EOF
+-------------------------------------------------+
            csv不重复号码总个数：" $number "
      -----------------------------------------
+-------------------------------------------------+
EOF
}
show_nums1
if [[ $allnumber -eq number ]];then
  echo "号码写入完成"
  echo "共写入: $allnumber" 
  else
  echo "写入丢失请对比csv与redis库"
fi

