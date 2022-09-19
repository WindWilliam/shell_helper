#!/bin/sh

###
# @Author: zf
# @Date: 2022-09-18 23:34:13
# @LastEditTime: 2022-09-19 23:16:36
# @LastEditors: zf
# @Description: command simplified for k8s(no namespace)
###

# 1.重启服务 update nginx.yaml
function update() {
    local yaml=$1
    # 文件是否存在
    if [[ ! -f "$yaml" ]]; then
        echo '${yaml}文件不存在'
    else
        echo 更新 $yaml
        kubectl delete -f $yaml
        sleep 3s
        kubectl apply -f $yaml
        sleep 3s
        local name=${yaml%.*}
        echo name为 $name
        kubectl get po -n pie-engine-ai | grep $name
    fi
}

# 2.查看日志 logs nginx ("--since 5m")
function log() {
    local name=$1
    local kid=$(kubectl get po -n pie-engine-ai | grep $name | head -n 1 | awk '{print $1}')
    echo pod名称为 $kid
    if [ ! -n "$2" ]; then
        kubectl logs -f $kid -n pie-engine-ai
    else
        echo $2
        kubectl logs $2 $kid -n pie-engine-ai
    fi
}

# 3.查看状态 po nginx
function po() {
    local name=$1
    echo 查看服务 $name
    kubectl get po -n pie-engine-ai | grep $name
}

# 4.获取服务 svc nginx
function svc() {
    local name=$1
    echo 查看服务 $name
    kubectl get svc -n pie-engine-ai | grep $name
}

# 5.其他
function dft() {
    echo 默认追加 $@
    #echo kubectl -n pie-engine-ai $@
    kubectl -n pie-engine-ai $@
}

# 以下为代码

echo '========开始========'
echo

if [[ $1 = 'update' ]]; then
    echo 更新命令: $2
    if [ ! -n "$2" ]; then
        echo 缺失yaml文件名参数
    else
        update $2
    fi
elif [[ $1 = 'log' ]]; then
    echo 日志命令，应用过滤: $2
    if [ ! -n "$2" ]; then
        echo 缺失应用过滤名称参数
    else
        log $2 "$3"
    fi
elif [[ $1 = 'po' ]]; then
    echo pod命令，过滤参数: $2
    if [ ! -n "$2" ]; then
        echo 缺失应用过滤名称参数
    else
        po $2
    fi
elif [[ $1 = 'svc' ]]; then
    echo svc命令，过滤参数: $2
    if [ ! -n "$2" ]; then
        echo 缺失服务过滤名称参数
    else
        svc $2
    fi
elif [[ $1 = 'help' ]]; then
    echo '===使用说明文档==='
    echo '1.重启服务 update nginx.yaml'
    echo '2.查看日志 logs nginx ("--since 5m")'
    echo '3.查看状态 po nginx'
    echo '4.获取服务 svc nginx'
    echo '5.其他(省略kubectl -n pie-engine-ai的命令） '
else
    echo 其他命令: $*
    dft $@
fi

echo
echo '========结束========'
