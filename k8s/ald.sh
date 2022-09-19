#!/bin/sh

###
# @Author: zf
# @Date: 2022-09-19 23:26:12
# @LastEditTime: 2022-09-19 23:40:32
# @LastEditors: zf
# @Description: apply,list and delete pod
###

# yaml文件名
yaml=predict-nginx.yaml
function updateYaml() {
    if [[ ! -n "$1" ]]; then
        yaml=$1
    fi
}

# pod过滤名
pod=${yaml%.*}
function updatePod() {
    if [[ ! -n "$1" ]]; then
        pod=$1
    fi
}
# 更新yaml和pod参数
function updateParams() {
    local suffix
    if [[ ! -n "$1" ]]; then
        suffix=${yaml:0-4}
    fi
    # 第一个参数是不是yaml结尾的
    if [[ $suffix = 'yaml' ]]; then
        updatePod $1
        updateYaml $2
    else
        updateYaml $1
        updatePod $2
    fi
}

if [[ $1 = 'd' ]]; then
    updateYaml $2
    echo 命令d,删除yaml: $yaml
    kubectl delete -f $yaml
elif [[ $1 = 'a' ]]; then
    updateYaml $2
    echo 命令a,应用yaml: $yaml
    kubectl apply -f $yaml
elif [[ $1 = 'l' ]]; then
    updatePod $2
    echo 命令l,查看pod: $pod
    kubectl get po -n pie-engine-ai | grep $pod
elif [[ $1 = 'dal' ]]; then
    updateParams $2 $3
    echo 命令dal,一键式更新
    echo yaml: $yaml
    echo pod: $pod
    # source ./pk.sh
    kubectl delete -f $yaml
    sleep 3s
    kubectl apply -f $yaml
    sleep 3s
    kubectl get po -n pie-engine-ai | grep $pod
else
    echo "不支持的命令"
fi
