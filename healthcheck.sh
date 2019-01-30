#!/bin/bash
HEALTHCHECK_INTERVAL=${HEALTHCHECK_INTERVAL:-'3'}
step=$((HEALTHCHECK_INTERVAL%60))
for ((i=0;i<60;i=(i+step))); do
    sleep $step
    cd /root/PyOne
    nc -z 127.0.0.1 6379
    if [ $? != 0 ];then
        rm -rf /root/PyOne/dump.rdb
        redis-server --daemonize yes
    fi
    nc -z 127.0.0.1 27017
    if [ $? != 0 ];then
        mongod --dbpath /data/mongodb/db --fork --logpath /data/mongodb/log/mongodb.log
    fi
    nc -z 127.0.0.1 6800
    if [ $? != 0 ];then
        aria2c -D --conf-path=/data/aria2/aria2.conf
    fi
    nc -z 127.0.0.1 ${PORT:-80}
    if [ $? != 0 ];then
        supervisorctl -c /root/PyOne/supervisord.conf restart pyone
    fi
done