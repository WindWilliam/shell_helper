#!/bin/sh

###
# @Author: zf
# @Date: 2022-09-18 23:28:55
# @LastEditTime: 2023-03-24 23:53:08
# @LastEditors: zf
# @Description: decompress gz file which starts with special name
###

# 解压到文件夹路径
folder="/dist"
# 压缩包文件前缀
prefix="pltest"

# 删除旧数据
sudo rm -rf $folder

filename=$(ls -lt | grep $prefix.*.tar.gz | head -n 1 | awk '{print $9}')
echo "准备解压$filename"
tar -zxf $filename -C $folder

num=$(ls -l ./ | grep $prefix.*.tar.gz | wc -l | awk '{print $1}')
echo "部署包个数$num"

if [ $num -gt 3 ]; then
    fileearly=$(ls -tr | grep $prefix.*.tar.gz | head -n 1 | awk '{print $1}')
    echo "删除$fileearly"
    sudo rm -rf $fileearly
else
    echo "无需删除文件"
fi

# 查看gz包里的文件列表
#  tar -ztf  $filename
