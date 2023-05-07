#!/bin/bash

chmod +x tools/stop.sh
. tools/stop.sh all

rm -r log/*

echo closing gamecore

sleep 2s

curl -X POST 'http://dock-comp-battlesrv-1:12345/kaiwu_drl.BattleSvr/Stop' -H "Content-Type:application/json"  -v