#!/bin/bash

# timezone
ln -sf /usr/share/zoneinfo/${TZ:-"Asia/Shanghai"} /etc/localtime
echo ${TZ:-"Asia/Shanghai"} > /etc/timezone

# sshd
if [ -n "${SSH_PASSWORD}" ];then
    mkdir -p /var/run/sshd
    echo root:${SSH_PASSWORD} | chpasswd
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    /usr/sbin/sshd
fi

# redis
redis-server --daemonize yes

# mongodb
mkdir -p /data/mongodb/db /data/mongodb/log
mongod --dbpath /data/mongodb/db --fork --logpath /data/mongodb/log/mongodb.log

# aria2
mkdir -p /data/aria2/download 
cp -rf /aria2.conf /data/aria2/aria2.conf
sed -i "s|rpc-secret=.*|rpc-secret=${ARIA2_SECRET:-aria2-secret}|" /data/aria2/aria2.conf
touch /data/aria2/aria2.session
aria2c -D --conf-path=/data/aria2/aria2.conf

# pyOne
cp -rfa /etc/PyOne /root
if [ ! -e "/root/PyOne/config.py" ];then
    cp -rf /root/PyOne/config.py.sample /root/PyOne/config.py
fi

# update config.py
source /update.sh
update_config
sed -i "s|ARIA2_SECRET=.*|ARIA2_SECRET=\"${ARIA2_SECRET:-aria2-secret}\"|" /root/PyOne/config.py

# supervisord
cp -rf /supervisord.conf /root/PyOne/supervisord.conf
sed -i "s|0.0.0.0.*|0.0.0.0:${PORT:-80} run:app|" /root/PyOne/supervisord.conf
supervisord -c /root/PyOne/supervisord.conf

# crontab
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

# show log
touch /root/PyOne/pyone.log
tail -f /root/PyOne/pyone.log

wait