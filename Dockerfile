FROM python:2.7.15-jessie

COPY docker-entrypoint.sh healthcheck.sh update.sh aria2c aria2.conf supervisord.conf /

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 && \
    echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.6 main" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list && \
    apt-get update -q && \
    apt-get install -yq --no-install-recommends \
        vim \
        cron \
        mongodb-org \
        redis-server \
        netcat-openbsd \
        openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mv /aria2c /usr/local/bin && \
    chmod +x /docker-entrypoint.sh /healthcheck.sh /update.sh /usr/local/bin/aria2c && \
    git clone https://github.com/abbeyokgo/PyOne.git /etc/PyOne && \
    pip install -r /etc/PyOne/requirements.txt && \
    ssh-keygen -A

WORKDIR /root/PyOne
VOLUME [ "/data", "/root/PyOne" ]
ENTRYPOINT ["/docker-entrypoint.sh"]