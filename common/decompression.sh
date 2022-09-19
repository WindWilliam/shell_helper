#!/bin/sh

###
# @Author: zf
# @Date: 2022-09-18 23:28:55
# @LastEditTime: 2022-09-19 23:34:37
# @LastEditors: zf
# @Description: decompress zip file that starts with special name
###

# 解压文件夹名称
folder=dist

# 压缩包文件前缀
prefix=pltest
function updatePrefix() {
    if [[ ! -n "$1" ]]; then
        prefix=$1
    fi
}

updatePrefix $1

# remove folder before
sudo rm -rf $folder

filename=$(ls -lt | grep $prefix.*.zip | head -n 1 | awk '{print $9}')
echo 准备解压$filename
unzip -qO UTF-8 $filename

# unzip -q $filename -d $folder

num=$(ls -l ./ | grep $prefix.*.zip | wc -l | awk '{print $1}')
echo 部署包个数$num

if [ $num -gt 2 ]; then
    fileearly=$(ls -tr | grep $prefix.*.zip | head -n 1 | awk '{print $1}')
    echo 删除$fileearly
    sudo rm -rf $fileearly
else
    echo "无需删除文件"
fi

sudo rm -rf $folder
