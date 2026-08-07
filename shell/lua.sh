#!/bin/bash
file=/root/registertoken.lua
target_num=3000
N_row= grep -n "if[[:space:]]*tonumber(ups[i])[[:space:]]*\<" $file
replace_num=`cat $file |grep "if[[:space:]]*tonumber"|tr -d [a-zA-Z\(\)\<]|tr -d [[:space:]]`
echo "更换之前的数量"
echo $replace_num


echo "目标数量"
echo "$target_num"
echo "sed -i '/if[[:space:]]*tonumber/s/[[:digit:]]*//g;s/[[:space:]]*if[[:space:]]*tonumber(ups\[i])[[:space:]]*<[[:space:]]/&'$replace_num'/' $file"
sed -i '/if[[:space:]]*tonumber/s/[[:digit:]]*//g;s/[[:space:]]*if[[:space:]]*tonumber(ups\[i])[[:space:]]*<[[:space:]]/&'$replace_num'/  $file