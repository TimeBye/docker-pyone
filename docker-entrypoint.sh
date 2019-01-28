#!/bin/bash

ln -sf /usr/share/zoneinfo/${TZ:-"Asia/Shanghai"} /etc/localtime
echo ${TZ:-"Asia/Shanghai"} > /etc/timezone

echo "* * * * * /healthcheck.sh" > /tmp/cron.`whoami`
if [ -z ${DISABLE_REFRESH_CACHE} ];then
    REFRESH_CACHE_NEW=${REFRESH_CACHE_NEW:-"*/15 * * * *"}
    REFRESH_CACHE_ALL=${REFRESH_CACHE_ALL:-"0 3 */1 * *"}
    echo "${REFRESH_CACHE_ALL} python /root/PyOne/function.py UpdateFile all" >> /tmp/cron.`whoami`
    echo "${REFRESH_CACHE_NEW} python /root/PyOne/function.py UpdateFile new" >> /tmp/cron.`whoami`
fi
crontab -u `whoami` /tmp/cron.`whoami`
cat /etc/os-release | grep Alpine >/dev/null 2>&1
if [ $? == 0 ];then
    crond
else
    service cron restart
fi

if [ -n ${SSH_PASSWORD} ];then
    mkdir -p /var/run/sshd
    echo root:${SSH_PASSWORD} | chpasswd
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    /usr/sbin/sshd
fi

if [ ! -f "/root/PyOne/config.py" ];then
    cp -rf /etc/PyOne/* /root/PyOne
    cp -rf /root/PyOne/config.py.sample /root/PyOne/config.py
fi

if [ ! -f "/data/aria2/aria2.conf" ];then
    mkdir -p /data/aria2/download 
    cp -rf /aria2.conf /data/aria2/aria2.conf
    sed -i "s|aria2-secret|${ARIA2_SECRET:-"aria2-secret"}|" /data/aria2/aria2.conf
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