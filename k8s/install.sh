#!/bin/sh
###
# @Author: zf
# @Date: 2023-03-15 23:03:12
# @LastEditTime: 2023-03-18 22:44:23
# @LastEditors: zf
# @Description: 命令安装和更新脚本
###

# 当前安装命令：kfk，对应脚本文件：kfk.sh
name="kfk"
file="$name.sh"

# 1. 原始文件存在校验
if [ ! -f "$file" ]; then
    echo "$file文件不存在，安装失败。"
    exit 1
fi

# 2. 命令安装权限校验
dir="/bin"
if [ ! -w "$dir" ]; then
    echo "当前用户无权限写文件，请提升执行命令权限"
    exit 1
fi

# 3. 安装/更新
tp="安装"
pos="$dir/$name"
if command -v $name >/dev/null 2>&1; then
    tp="更新"
    # 命令已经存在，直接替换文件内容
    cat $file >$pos
else
    # 复制文件并授权
    cp $file $pos
    chmod u+x $pos
fi

# 4. 测试安装/更新结果
if command -v $name >/dev/null 2>&1; then
    echo "$name 命令 $tp成功！"
else
    echo "$name 命令 $tp失败！"
fi

# 以下放弃 #

# # 1.检测是否已存在
# pos="$dir/$name"
# cmd="cp"
# if [ -f "$pos" ]; then
#     if [ "$1" = "-f" ]; then
#         # 不能放在引号里
#         cmd=\cp
#         # 强制覆盖
#         cmd="$cmd -f"
#     fi
# fi

# # 2.拷贝文件至对应目录
# $cmd $file $pos

# # 3.文件授予可执行权限
# chmod u+x $pos
