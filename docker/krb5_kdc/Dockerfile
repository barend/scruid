# Copied from https://github.com/gcavalcante8808/docker-krb5-server
FROM alpine

RUN apk add --no-cache krb5-server krb5 supervisor tini

ADD content/docker-entrypoint.sh /
ADD content/supervisord.conf     /etc/supervisord.conf
ADD content/krb5.conf            /etc/krb5.conf
ADD content/kdc.conf             /var/lib/krb5kdc/kdc.conf

VOLUME /var/lib/krb5kdc

EXPOSE 749 464 88

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/docker-entrypoint.sh"]
