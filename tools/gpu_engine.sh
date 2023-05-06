#!/bin/bash


# gpu_engine.sh 主要用于处理异构GPU场景下的拷贝文件问题

chmod +x tools/common.sh
. tools/common.sh

if [ $# -ne 1 ];
then
    echo -e "\033[31m useage: sh tools/gpu_engine.sh gpu_type, such as: sh tools/gpu_engine.sh A100|V100|T4|P100 \033[0m"
    exit -1
fi

gpu_machine_type=$1

# 目前支持的GPU类型为A100, V100, T4
gpu_machie_array=("A100" "V100" "T4" "P100")
if [[ ! "${gpu_machie_array[@]}" =~ "$gpu_machine_type" ]]
then
    echo -e "\033[31m current GPU machine is not A100, V100, T4, P100 \033[0m"

    # 由于存在在非GPU的机器上执行, 故这里加上提示, 实在找不到GPU则返回CPU的, 此时等价于GPU的T4
    gpu_machine_type=CPU
fi

# 如果机器类型是CPU, 则不需要拷贝TensorRT的依赖, 否则会引起异常
if [ $gpu_machine_type == "CPU" ];
then
    echo -e "\033[31m current GPU machine is $gpu_machine_type, so not need copy tensorrt file \033[0m"
    exit 0
fi

# 拷贝TensorRT依赖, 包括libtrt_infer.so, trt_interface.so, batch512_FP16.gie, cas_interface.so, actor_cpp_server
tensorrt_engine_dir=/data/projects/kaiwu-fwk/framework/server/cpp/src/actor/trt_inference
file_exist_then_copy ${tensorrt_engine_dir}/gpu_engine/${gpu_machine_type}/libtrt_infer.so /data/projects/kaiwu-fwk/framework/server/cpp/lib;
file_exist_then_copy ${tensorrt_engine_dir}/gpu_engine/${gpu_machine_type}/trt_interface.cpython-37m-x86_64-linux-gnu.so ${tensorrt_engine_dir};
file_exist_then_copy ${tensorrt_engine_dir}/gpu_engine/${gpu_machine_type}/batch512_FP16.gie ${tensorrt_engine_dir}/model/trt/;
file_exist_then_copy ${tensorrt_engine_dir}/gpu_engine/${gpu_machine_type}/actor_server.cpython-37m-x86_64-linux-gnu.so ${tensorrt_engine_dir};
file_exist_then_copy ${tensorrt_engine_dir}/gpu_engine/${gpu_machine_type}/actor_cpp_server ${tensorrt_engine_dir};
judge_succ_or_fail $? "cp tesnort file"

file_exist_then_copy /data/projects/kaiwu-fwk/framework/server/cpp/lib/libnvinfer.so.8 /usr/lib64/; 
file_exist_then_copy /data/projects/kaiwu-fwk/framework/server/cpp/lib/libnvinfer_plugin.so.8 /usr/lib64/; 
file_exist_then_copy /data/projects/kaiwu-fwk/framework/server/cpp/lib/libtrt_infer.so /usr/lib64/
judge_succ_or_fail $? "cp tesnort so file"


# 其他操作
