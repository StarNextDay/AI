

#!/bin/bash

chmod +x tools/start.sh
. tools/start.sh all no_config sgame_1v1 no_self_play

echo starting gamecore

sleep 5s

# cd /data/projects/kaiwu-fwk/app/sgame_1v1/tools 
# chmod +x start_multi_game.sh
# . ./start_multi_game.sh 1 /data/projects/kaiwu-fwk/conf/client.json  >/dev/null 2>&1 &

curl -X POST 'http://dock-comp-battlesrv-1:12345/kaiwu_drl.BattleSvr/Start' -H "Content-Type:application/json" -d '{"max_battle": 1}' -v


while true
do
    flag=1
    msg=""
    array=("aisrv" "actor" "learner" "modelpool")
    for process_name in ${array[@]}
    do
        process_num=`ps -ef | grep $process_name | grep -v grep | grep -v 'start.sh' | grep -v 'check.sh' | wc -l`
        if [ $flag -gt $process_num ]
        then
            flag=0
        fi
        msg="$msg \n\033[32m $process_name check success, process num is $process_num \033[0m"
    done

    if [ `wc -l /data/ckpt/sgame_1v1_ppo/checkpoint | awk '{print $1}'` -gt 2 ]
    then
        echo -e "\033[32m **** Test Success **** \033[0m" 
        chmod +x tools/stop_test.sh
        . tools/stop_test.sh
        exit 0
    fi

    if [ $flag -eq 1 ]
    then
        echo "**** Testing ****"
        echo -e $msg
    else
        echo -e "\033[32m there are some process exit \033[0m" 
        chmod +x tools/stop_test.sh
        . tools/stop_test.sh
        exit 255
    fi
    sleep 10s
done
    
    