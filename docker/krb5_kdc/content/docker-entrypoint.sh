#!/bin/sh
if [ ! -f "/var/lib/krb5kdc/principal" ]; then

    echo "No Krb5 Database Found. Creating One with provided information"

    if [ -z ${KRB5_PASS} ]; then
        echo "No Password for kdb provided ... Creating One"
        KRB5_PASS=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`
        echo "Using Password ${KRB5_PASS}"
    fi

    if [ -z ${DRUID_PASS} ]; then
        echo "No Password for druid provided ... Creating One"
        KRB5_PASS=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`
        echo "Using Password ${KRB5_PASS}"
    fi

    if [ -z ${SCRUID_PASS} ]; then
        echo "No Password for scruid provided ... Creating One"
        KRB5_PASS=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`
        echo "Using Password ${KRB5_PASS}"
    fi

echo "Creating Default Policy - Admin Access to */admin"
echo "*/admin@SCRUID_DEFAULT *" > /var/lib/krb5kdc/kadm5.acl
echo "*/service@SCRUID_DEFAULT aci" >> /var/lib/krb5kdc/kadm5.acl

    echo "Creating Temp pass file"
cat <<EOT > /etc/krb5_pass
${KRB5_PASS}
${KRB5_PASS}
EOT

    echo "Creating krb5util database"
    kdb5_util create -r SCRUID_DEFAULT < /etc/krb5_pass
    rm /etc/krb5_pass

    echo "Creating Admin Account"
    kadmin.local -q "addprinc -pw ${KRB5_PASS} admin/admin@SCRUID_DEFAULT"

    echo "Creating Druid Server Account"
    kadmin.local -q "addprinc -pw ${DRUID_PASS} druid/scruid_druid_krb5.scruid_default@SCRUID_DEFAULT"

    echo "Creating Druid End-user Account"
    kadmin.local -q "addprinc -pw ${SCRUID_PASS} scruid@SCRUID_DEFAULT"

    echo "Export Druid Server Keytab"
    kadmin.local xst -k /etc/keytabs/scruid_druid_krb5.kt druid/scruid_druid_krb5.scruid_default@SCRUID_DEFAULT

    echo "Export Druid User Keytab"
    kadmin.local xst -k /etc/keytabs/scruid_user.kt scruid@SCRUID_DEFAULT
fi

/usr/bin/supervisord -c /etc/supervisord.conf
