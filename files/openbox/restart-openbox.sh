#!/bin/bash
pid=$(ps -ef | grep tty1 | grep bash | awk '{print $2}')
setsid bash -c "sleep 2 ; sudo kill -9 $pid" &
setsid bash -c 'sudo pkill -9 X'

