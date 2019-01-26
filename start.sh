#!/bin/bash

if [ ! -f "/root/PyOne/config.py" ];then
    mv /root/PyOne.sample/* /root/PyOne
    cp -f /root/PyOne/config.py.sample /root/PyOne/config.py
fi

redis-server &
aria2c --conf-path=/data/aria2/aria2.conf &
mongod --dbpath /data/db --fork --logpath /data/log/mongodb.log &

cd /root/PyOne && gunicorn -k eventlet -b 0.0.0.0:34567 run:app