#!/bin/bash

# @Author: zf
# @Date: 2022-01-13 14:19:45
# @LastEditTime: 2023-03-25 16:24:00
# @LastEditors: zf
# @Description: k8s通用服务简化

# 0.0 通用变量方法------------------开始
# k8s的命名空间
ns=""
# 过滤结果
res=""

# 命名空间的环境变量（当前shell有效，故需要用source执行命令）
# k8s namespace
# k18e

# 获取当前命名空间
function getNs() {
    if [ -n "$k18e" ]; then
        ns="-n $k18e"
    else
        # 默认命名空间
        ns="-n pie-engine-ai"
    fi
}

# 获取过滤结果
# 接受两个参数：
# 第一个为过滤参数，如 nginx
# 第二个为类型参数，默认为 pod
function getGrepRes() {
    local filter=$1
    local type="pod"
    if [ -n "$2" ]; then
        type=$2
    fi

    local kid=$(kubectl get $type $ns | grep $filter)
    echo "$kid" | nl
    echo

    local line=1
    local num=$(echo "$kid" | wc -l)
    # 设置获取的
    if [ $num -ne 1 ]; then
        read -p "请选择对应的行号：" line
        echo
    fi
    # 此处必须是单引号，注意不要被替换
    res=$(echo "$kid" | sed -n ${line}p | awk '{print $1}')

    if [ -z "$res" ]; then
        echo "当前${type}为空，请确认过滤条件 $filter 是否正确"
        echo
        exit 1
    else
        echo "当前${type}为： $res"
        echo
    fi
}
# 0.0 通用方法------------------结束

# 主体方法------------------开始

# 0.设置命名空间  ns pie-engine-ai
# 当前shell有效，故需要用source执行命令
function setNs() {
    local now=$1
    if [ -n "$now" ]; then
        # 当前shell有效，故需要用source执行命令
        export k18e=$now
    else
        echo "缺失命名空间参数！"
        echo
        exit 1
    fi
}

# 1.重启（更新）功能  ud nginx.yaml
# 根据名词你过来判断是pod还是svc
function ud() {
    local yaml=$1
    # 文件是否存在
    if [ ! -f "$yaml" ]; then
        echo "${yaml}文件不存在"
        echo
        exit 1
    else
        echo "开始更新 $yaml"
        kubectl delete -f $yaml
        sleep 3s
        kubectl apply -f $yaml
        sleep 3s
        echo "完成更新 $yaml"
        local name=${yaml%.*}
        # 此处区分一下pod和svc
        if [[ $name == *svc* ]]; then
            name=${name//-svc/}
            echo "svc为$name 的结果："
            kubectl get svc $ns | grep $name
        else
            echo "pod为$name 的结果："
            kubectl get pod $ns | grep $name
        fi
    fi
}

# 2.查看日志  lg nginx [t100]
# 可选参数，如 t100，为--tail=100不传则默认为t100
# 可选参数，如 s5m，为--since=5m
# 可选参数，如 -f，k8s log本身参数（不仅限-f）
function lg() {
    local filter=$1
    getGrepRes $1

    local extra=$2
    # 此处三种格式，s3m，t100，k8s默认参数；不传则默认为--tail=100
    if [ -z "$extra" ]; then
        local params="--tail=100"
        echo "默认：$params"
        echo
        kubectl logs $res $ns $params
    elif [[ $extra =~ ^t[0-9]+$ ]]; then
        local params=${extra/#t/"--tail="}
        echo "tail参数: $params"
        echo
        kubectl logs $res $ns $params
    elif [[ $extra =~ ^s[0-9]+[a-z]$ ]]; then
        local params=${extra/#s/"--since="}
        echo
        echo "since参数: $params"
        kubectl logs $res $ns $params
    else
        shift
        echo "其他： $*"
        echo
        kubectl logs $res $ns $@
    fi
}

# 3.查看状态 po nginx [pod]
# 可选参数，默认为pod，k8s get本身参数（不仅限pod）
function po() {
    local type=$1
    # 此处特殊，过滤条件可以为空，故放于$2
    local filter=$2
    if [ -z "$filter" ]; then
        kubectl get $type $ns
    else
        echo "查看$type $filter"
        echo
        kubectl get $type $ns | grep $filter
    fi
}

# 4.查看描述 des nginx [pod]
# 可选参数，默认为pod，k8s describe本身参数（不仅限pod）
function des() {
    local filter=$1
    local type="pod"
    if [ -n "$2" ]; then
        type=$2
    fi
    getGrepRes $filter $type

    kubectl describe $type $res $ns
}

# 5.进入容器 bash/sh nginx
function shell() {
    local filter=$1
    getGrepRes $filter

    local cmd=$2
    kubectl exec -it $res $ns $cmd
}

# 66.查看帮助 helper
function helper() {
    echo "===使用说明文档==="
    echo "0.设置命名空间 source ns pie-engine-ai"
    echo "1.重启服务 ud nginx.yaml"
    echo "2.查看日志 lg nginx [t100]"
    echo "3.查看状态 po nginx [pod]"
    echo "4.查看描述 des nginx"
    echo "5.进入容器 bash/sh nginx"

    echo "66.查看本命令的使用说明 help"

    echo "555.不使用命名空间 o ***(等同kubectl ***)"
    echo "666.其他(等同kubectl ${ns} ***的命令) "
}

# 555.其他
function origin() {
    echo "不使用命名空间 $@"
    kubectl $@
}

# 666.其他
function dft() {
    echo "默认追加 $@"
    kubectl $ns $@
}
# 主体方法------------------结束

# 功能主体------------------
getNs

echo
echo "========开始========"
echo "当前命名空间为 $ns"
echo

case "$1" in
"ns")
    setNs $2
    # 重新获取命名空间
    getNs
    echo "更新后的命名空间为 $ns"
    ;;
"ud")
    ud $2
    ;;
"lg")
    shift
    # 移除$1，传递剩余参数
    lg $@
    ;;
"po")
    tp="pod"
    if [ -n "$3" ]; then
        tp=$3
    fi
    po $tp $2
    ;;
"des")
    shift
    # 移除$1，传递剩余参数
    des $@
    ;;
"sh" | "bash")
    shell $2 $1
    ;;
"help" | "--help" | "")
    helper
    ;;
"o" | "origin")
    shift
    # 移除$1，传递剩余参数
    origin $@
    ;;
*)
    dft $*
    ;;
esac

echo "========结束========"
echo
# 功能主体------------------
