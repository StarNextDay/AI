#!/bin/bash

# 清理机器上的tensorflow的checkpoint文件的功能

chmod +x tools/common.sh
. tools/common.sh

# 直接删除对应的文件夹
rm -rf /data/ckpt/*
judge_succ_or_fail $? "/data/ckpt/ clear"

rm -rf /data/summary/*
judge_succ_or_fail $? "/data/summary/ clear"

rm -rf /data/pb_model/*
judge_succ_or_fail $? "/data/pb_model/ clear"