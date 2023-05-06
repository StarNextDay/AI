from multiprocessing import Process
from framework.common.config.config_control import CONFIG
from framework.common.utils.kaiwudrl_define import KaiwuDRLDefine
from framework.common.utils.common_func import stop_process_by_name, python_exec_shell
from tools.learner_step_check import countCkpt
import framework.server.python.learner.learner as learner
import framework.server.python.actor.actor as actor
import framework.server.python.aisrv.aisrv as aisrv
import time
import requests as req
import click
import os

# 训练

@click.command()
@click.option('--batch_size', default=0, help='batch_size参数，非必须，有默认值')
def train(batch_size: int = 0):
    '''
    支持动态调整batch_size大小
    '''
    
    # 启动训练相关进程
    procs = []
    procs.append(Process(target=learner.main, name="learner"))
    procs.append(Process(target=actor.main, name="actor"))
    procs.append(Process(target=aisrv.main, name="aisrv"))
    procs.append(Process(target=python_exec_shell, args=('sh tools/start_modelpool.sh learner',), name='modelpool'))

    for proc in procs:
        proc.start()
        time.sleep(10)
        check(proc)



   # 调整batch_size
    if batch_size > 0:
        CONFIG.train_batch_size = batch_size
        print(f"success to update batch_size is {CONFIG.train_batch_size}")

    # 计算已有的checkpoint数量
    oldCkpt = countCkpt()

    # 启动对战
    stopBattle()
    startBattle()

    # 监听进程是否退出
    while True:
        newCkpt = countCkpt()
        # 有新的checkpoint产出即退出
        if newCkpt - oldCkpt > 0 :
            stop_process_by_name(KaiwuDRLDefine.SERVER_MODELPOOL)
            stop_process_by_name(KaiwuDRLDefine.SERVER_MODELPOOL_PROXY)
            os.system("ps -ef|grep train_test|grep -v grep|awk '{print $2}'|xargs kill -9")
        
        time.sleep(2)
        for proc in procs:
            check(proc)


def check(proc: Process):
    if proc.is_alive():
        print(f'{proc.name} is alive')
    else:
        raise Exception(f'{proc.name} is not alive, please check error log')


def startBattle():
    rsp = req.post(
        "http://127.0.0.1:12345/kaiwu_drl.BattleSvr/Start", json={"max_battle": 1})
    if rsp.status_code > 300:
        raise Exception("start battle fail")


def stopBattle():
    rsp = req.post("http://127.0.0.1:12345/kaiwu_drl.BattleSvr/Stop", json={})
    if rsp.status_code > 300:
        raise Exception("stop battle fail")


if __name__ == '__main__':
    train()
