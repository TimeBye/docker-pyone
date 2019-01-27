#!/bin/bash

if [ -z $DISABLE_CRON ];then
    REFRESH_CACHE_ALL=${REFRESH_CACHE_ALL:-"0 3 */1 * *"}
    REFRESH_CACHE_NEW=${REFRESH_CACHE_NEW:-"*/15 * * * *"}
    rm -rf /tmp/cron.`whoami`
    echo "${REFRESH_CACHE_ALL} python /root/PyOne/function.py UpdateFile all" >> /tmp/cron.`whoami`
    echo "${REFRESH_CACHE_NEW} python /root/PyOne/function.py UpdateFile new" >> /tmp/cron.`whoami`
    crontab -u `whoami` /tmp/cron.`whoami`
    service cron restart
fi

if [ ! -f "/root/PyOne/config.py" ];then
    cp -rf /root/PyOne.sample/* /root/PyOne
    cp -rf /root/PyOne/config.py.sample /root/PyOne/config.py
fi

if [ ! -f "/data/aria2/aria2.conf" ];then
    mkdir -p /data/aria2/download 
    cp -rf /aria2.conf /data/aria2/aria2.conf
    sed -i "s|aria2-secret|${ARIA2_SECRET:-aria2-secret}|" /data/aria2/aria2.conf
    touch /data/aria2/aria2.session
fi

if [ ! -f "/data/mongodb/log/mongodb.log" ];then
    mkdir -p /data/mongodb/db /data/mongodb/log
fi

if [ ! -f "/root/PyOne/supervisord.conf" ];then
    cp -rf /supervisord.conf /root/PyOne/supervisord.conf
    sed -i "s|34567|${PORT:-34567}|" /root/PyOne/supervisord.conf
    touch /root/PyOne/pyone.log
fi

redis-server &
aria2c --conf-path=/data/aria2/aria2.conf &
mongod --dbpath /data/mongodb/db --fork --logpath /data/mongodb/log/mongodb.log &
wait $!

supervisord -c /root/PyOne/supervisord.conf
tail -f /root/PyOne/pyone.log
wait