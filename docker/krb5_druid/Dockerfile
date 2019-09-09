FROM fokkodriesprong/docker-druid

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes \
     krb5-user \
     libkrb5-dev \
 && rm -rf /var/lib/apt/lists/*

ADD etc/krb5.conf /etc/krb5.conf
ADD druid.conf.d  /opt/druid/conf/druid/single-server/micro-quickstart/
