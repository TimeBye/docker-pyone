#!/bin/bash

if [ ! -f "/root/PyOne/config.py" ];then
    mv /root/PyOne.sample/* /root/PyOne
    cp -f /root/PyOne/config.py.sample /root/PyOne/config.py
fi

redis-server &
aria2c --conf-path=/data/aria2/aria2.conf &
mongod --dbpath /data/mongodb/db --fork --logpath /data/log/mongodb/mongodb.log &
wait $!

gunicorn -k eventlet -b 0.0.0.0:${PORT-:"34567"} run:app &
wait