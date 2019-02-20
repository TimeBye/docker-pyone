FROM centos:7

COPY docker-entrypoint.sh healthcheck.sh aria2c aria2.conf supervisord.conf /

RUN \
    echo '[mongodb-org-4.0]' >> /etc/yum.repos.d/mongodb-org-4.0.repo && \
    echo 'name=MongoDB Repository' >> /etc/yum.repos.d/mongodb-org-4.0.repo && \
    echo 'baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/' >> /etc/yum.repos.d/mongodb-org-4.0.repo && \
    echo 'gpgcheck=1' >> /etc/yum.repos.d/mongodb-org-4.0.repo && \
    echo 'enabled=1' >> /etc/yum.repos.d/mongodb-org-4.0.repo && \
    echo 'gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc' >> /etc/yum.repos.d/mongodb-org-4.0.repo

RUN \
    curl -s https://bootstrap.pypa.io/get-pip.py | python && \
    yum -y install epel-release && \
    yum makecache && \
    yum -y update && \
    yum -y install \
        nc \
        vim \
        git \
        lsof \
        redis \
        cronie \
        mongodb-org \
        openssh-server && \
    yum clean all && \
    pip install supervisor && \
    mv /aria2c /usr/local/bin && \
    git clone https://github.com/abbeyokgo/PyOne.git /etc/PyOne && \
    sed -n "1,`grep -n "}" /etc/PyOne/update.sh | tail -1 | cut -d: -f1`p" /etc/PyOne/update.sh > /update.sh && \
    chmod +x /docker-entrypoint.sh /healthcheck.sh /update.sh /usr/local/bin/aria2c && \
    pip install -r /etc/PyOne/requirements.txt && \
    ssh-keygen -A

WORKDIR /root/PyOne
VOLUME [ "/data", "/root/PyOne" ]
ENTRYPOINT ["/docker-entrypoint.sh"]