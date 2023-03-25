#!/bin/bash

# @Author: zf
# @Date: 2022-09-19 23:26:12
# @LastEditTime: 2023-03-25 15:24:00
# @LastEditors: zf
# @Description: create,apply,list and delete

# 命名空间，可为空
ns="-n pie-engine-ai"
# yaml文件名称，可为空
yaml=ai-nginx.yaml

# 主体方法------------------开始

# 更新ns信息
function updateNs() {
    if [ -z "$ns" ]; then
        ns="-o wide -A"
    fi
    echo "命名空间过滤: $ns"
    echo
}
# 更新yaml信息
function updateYaml() {
    if [ -n "$1" ]; then
        yaml=$1
    elif [ -z "$yaml" ]; then
        yaml=$(ls -lt | grep .*.yaml | head -n 1 | awk '{print $9}')
    fi
}

# 校验yaml信息
function checkYaml {
    if [ "$1" = "list" ]; then
        if [ -z "$yaml" ]; then
            echo "yaml信息缺失,无法继续！"
            exit 1
        fi
    else
        # 文件是否存在
        if [ ! -f "$yaml" ]; then
            echo "$yaml 文件不存在,无法继续！"
            exit 1

        fi
    fi
}

# 展示信息
function listInfo {
    local name=${yaml%.*}
    # 此处区分一下pod和svc
    if [[ $name == *svc* ]]; then
        name=${name//-svc/}
        echo "svc为$name 的结果："
        echo
        kubectl get svc $ns | grep $name
    else
        echo "pod为$name 的结果："
        echo
        kubectl get pod $ns | grep $name
    fi
}
# 主体方法------------------结束

# 功能主体------------------

echo
echo "========开始========"
updateNs

# 第一个参数是否为yaml文件
cmd="dal"
if [[ $1 =~ \.yaml$ ]]; then
    updateYaml $1
    if [ -n "$2" ]; then
        cmd=$2
    fi
else
    updateYaml
    if [ -n "$1" ]; then
        cmd=$1
    fi
fi

# 解析命令
case "$cmd" in
"a")
    checkYaml
    echo 命令a,应用/更新yaml: $yaml
    kubectl apply -f $yaml
    ;;
"c")
    checkYaml
    echo 命令c,创建yaml: $yaml
    kubectl create -f $yaml
    ;;
"d")
    checkYaml
    echo "命令d,删除yaml: $yaml"
    kubectl delete -f $yaml
    ;;
"l")
    checkYaml "list"
    echo "命令l,展示对应pod: $pod"
    listInfo
    ;;
"dal")
    checkYaml
    echo "命令dal,一键式更新yaml: $yaml"
    kubectl delete -f $yaml
    sleep 3s

    kubectl apply -f $yaml
    sleep 3s

    listInfo
    ;;
*)
    echo "不支持的命令: $cmd"
    echo
    echo "当前支持命令格式为:"
    echo " a: 应用/更新yaml"
    echo " c: 创建yaml"
    echo " d: 删除yaml"
    echo " l: 展示对应pod"
    echo " dal:一键式更新yaml"
    ;;
esac

echo "========结束========"
echo
# 功能主体------------------

# create 和 apply 的区别

# kubectl create -f [yaml文件]
# 通过create创建的无法更新只能用于一次性的，想要更新必须先delete

# kubectl apply -f [yaml文件]
# 创建+更新，可以重复使用
