#!/bin/bash

if [ ! -f "/root/PyOne/config.py" ];then
    mv /root/PyOne.sample/* /root/PyOne
    cp -f /root/PyOne/config.py.sample /root/PyOne/config.py
fi

if [ ! -f "/root/PyOne/mongodb.lock" ];then
    mongod --dbpath /data/db --fork --logpath /data/log/mongodb.log &
    wait $!
    touch /root/PyOne/mongodb.lock
fi

redis-server &
aria2c --conf-path=/data/aria2/aria2.conf &
mongod -auth --bind_ip 127.0.0.1 --port 27017 --dbpath /data/db --fork --logpath /data/log/mongodb.log &
wait $!

cd /root/PyOne
gunicorn -k eventlet -b 0.0.0.0:34567 run:app &
wait $!

cat