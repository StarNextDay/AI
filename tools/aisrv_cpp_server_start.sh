#!/bin/bash


# aisrv_cpp_server_start.sh 主要用于拉起C++常驻进程

chmod +x tools/common.sh
. tools/common.sh

cd /data/projects/kaiwu-fwk/framework/server/cpp/src/aisrv/

# C++需要和python端的设置一致才可以采用共享内存通信
export G6SHMNAME=KaiwuDRL 

#c++调用python函数需要配置环境变量
export PYTHONPATH=$PYTHONPATH:/data/projects/kaiwu-fwk/
export PYTHONPATH=$PYTHONPATH:/data/projects/kaiwu-fwk/framework/server/cpp/src/aisrv/

# 默认绑在第一个核上, 但是需要根据机器具体情况进行, 推荐绑在最后开始数的CPU核上
myarray=()
args=$(echo ${myarray[*]})
cpu_ids=($(get_cpu_ids_by_lxcfs $args))

array_len=${#cpu_ids[@]}
read_from_actor_bind_cpu_idx=${cpu_ids[0]}
write_to_actor_bind_cpu_idx=${cpu_ids[0]}

if [ $array_len -ge 2 ];
then
    count=0
    for cpu in ${cpu_ids[@]}
    do
        if [ $count -eq 0 ];
        then
            read_from_actor_bind_cpu_idx=$cpu
            write_to_actor_bind_cpu_idx=$cpu
        else
            read_from_actor_bind_cpu_idx="$read_from_actor_bind_cpu_idx, $cpu"
            write_to_actor_bind_cpu_idx="$write_to_actor_bind_cpu_idx, $cpu"
        fi

        let count++
    done
fi

# 确保日志文件存在
aisrv_cpp_server_log_dir=/data/projects/kaiwu-fwk/
if [ ! -x "$aisrv_cpp_server_log_dir/log/aisrv" ];
then
    mkdir $aisrv_cpp_server_log_dir/log/
    mkdir $aisrv_cpp_server_log_dir/log/aisrv
fi

# 修改配置文件里的值, 主要是修改绑核逻辑
aisrv_cpp_server_conf=/data/projects/kaiwu-fwk/framework/server/cpp/conf/aisrv_server.ini
sed -i '/--read_from_actor_bind_cpu_idx/d' $aisrv_cpp_server_conf
sed -i '/--write_to_actor_bind_cpu_idx/d' $aisrv_cpp_server_conf

# 注意不要和已经有的配置项格式冲突
echo -e "\n--read_from_actor_bind_cpu_idx=$read_zmq_work_bind_cpu_idx" >> $aisrv_cpp_server_conf
echo -e "\033[32m read_from_actor_bind_cpu_idx  is $read_zmq_work_bind_cpu_idx \033[0m"
echo "--write_to_actor_bind_cpu_idx=$write_zmq_work_bind_cpu_idx" >> $aisrv_cpp_server_conf
echo -e "\033[32m write_to_actor_bind_cpu_idx  is $write_zmq_work_bind_cpu_idx \033[0m"

# 这里注意日志输出量的估算问题, 以免将磁盘空间占用完
./aisrv_cpp_server --flagfile /data/projects/kaiwu-fwk/framework/server/cpp/conf/aisrv_server.ini >$aisrv_cpp_server_log_dir/log/aisrv/aisrv_cpp_server.log 2>&1 &
judge_succ_or_fail $? "aisrv_cpp_server start"
