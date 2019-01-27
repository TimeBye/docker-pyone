#!/bin/bash

if [ ! -f "/root/PyOne/config.py" ];then
    cp -rf /root/PyOne.sample/* /root/PyOne
    cp -rf /root/PyOne/config.py.sample /root/PyOne/config.py
fi

if [ ! -f "/data/aria2/aria2.conf" ];then
    mkdir -p /data/aria2/download 
    cp -rf /aria2.conf /data/aria2/aria2.conf
    touch /data/aria2/aria2.session
fi

if [ ! -f "/data/mongodb/log/mongodb.log" ];then
    mkdir -p /data/mongodb/db /data/mongodb/log
fi

if [ ! -f "/root/PyOne/supervisord.conf" ];then
    cp -rf /root/PyOne/supervisord.conf.sample /root/PyOne/supervisord.conf
    sed -i "s|34567|${PORT:-34567}|" /root/PyOne/supervisord.conf
fi

redis-server &
aria2c --conf-path=/data/aria2/aria2.conf &
mongod --dbpath /data/mongodb/db --fork --logpath /data/mongodb/log/mongodb.log &
wait $!

supervisord -n -c /root/PyOne/supervisord.conf
wait