#!/bin/bash
# 进程查看脚本, 在k8s上用于查看进程的数目, 比如battlesrv和aisrv数量

if [ $# -ne 1 ];
then
    echo -e "\033[31m useage: sh tools/check_k8s_process.sh process_name, \n such as: sh tools/check_k8s_process.sh aisrv \n or sh tools/check_k8s_process.sh battlesrv \033[0m"
    
    exit -1
fi

process_name=$1
if [ $process_name == "aisrv" ];
then
    echo -e "\033[32m $process_name Running count:  \033[0m"
    kubectl get pod -o wide -n kaiwu-drl-prod | grep 5v5 | grep aisrv | grep Running  | wc -l
elif [ $process_name == "battlesrv" ];
then
    echo -e "\033[32m $process_name Running count:  \033[0m"
    kubectl get pod -o wide -n kaiwu-drl-prod | grep 5v5 | grep battlesrv | grep Running  | wc -l
elif [ $process_name == "all" ];
then
    echo -e "\033[32m aisrv Running count:  \033[0m"
    kubectl get pod -o wide -n kaiwu-drl-prod | grep 5v5 | grep aisrv | grep Running  | wc -l

    echo -e "\033[32m battlesrv Running count:  \033[0m"
    kubectl get pod -o wide -n kaiwu-drl-prod | grep 5v5 | grep battlesrv | grep Running  | wc -l
else
    echo -e "\033[31m useage: sh tools/check_k8s_process.sh process_name, \n such as: sh tools/check_k8s_process.sh aisrv \n or sh tools/check_k8s_process.sh battlesrv \033[0m"
    
    exit -1
fi
