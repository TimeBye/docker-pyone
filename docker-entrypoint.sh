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
if [ -e "/root/PyOne/config.py" ];then
    if [ ! -e "/root/PyOne/self_config.py" ];then
        cp -rf /root/PyOne/config.py /root/PyOne/self_config.py
    fi
fi
cp -rfa /etc/PyOne /root
if [ ! -e "/root/PyOne/self_config.py" ];then
    cp -rf /root/PyOne/self_config.py.sample /root/PyOne/self_config.py
fi

# update config.py
source /update.sh
upgrade
sed -i "s|ARIA2_SECRET=.*|ARIA2_SECRET=\"${ARIA2_SECRET:-aria2-secret}\"|" /root/PyOne/self_config.py

# supervisord
cp -rf /supervisord.conf /root/PyOne/supervisord.conf
sed -i "s|0.0.0.0.*|0.0.0.0:${PORT:-80} run:app|" /root/PyOne/supervisord.conf
supervisord -c /root/PyOne/supervisord.conf

# crontab
echo "* * * * * /healthcheck.sh" > /tmp/cron.`whoami`
if [ -z ${DISABLE_REFRESH_CACHE} ];then
    REFRESH_CACHE_NEW=${REFRESH_CACHE_NEW:-"*/15 * * * *"}
    REFRESH_CACHE_ALL=${REFRESH_CACHE_ALL:-"0 3 */1 * *"}
    echo "${REFRESH_CACHE_ALL} python /root/PyOne/app/utils/updatefile.py UpdateFile all" >> /tmp/cron.`whoami`
    echo "${REFRESH_CACHE_NEW} python /root/PyOne/app/utils/updatefile.py UpdateFile new" >> /tmp/cron.`whoami`
fi
crontab -u `whoami` /tmp/cron.`whoami`
OS_NAME=$(cat /etc/os-release | grep "^NAME=" | awk -F '=' '{print $2}')
if [[ $OS_NAME =~ "CentOS" || $OS_NAME =~ "Alpine" ]];then
    echo "crond"
fi
if [[ $OS_NAME =~ "Debian" ]];then
    echo "service cron restart"
fi

# show log
touch /root/PyOne/pyone.log
touch /root/PyOne/.install
tail -f /root/PyOne/pyone.log

wait