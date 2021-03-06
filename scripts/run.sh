#!/bin/bash
 
# start 1
#ls -la /etc/apache2/certs
rm -f /var/run/apache2/apache2.pid
/usr/sbin/apachectl -D FOREGROUND &
# start 2
#db_upgrade /var/lib/ldap/dn2id.bdb
#db_upgrade /var/lib/ldap/id2entry.bdb
#db_upgrade /var/lib/ldap/objectClass.bdb
#chown -R openldap:openldap /var/lib/ldap
#chown -R openldap:openldap /etc/ldap/slapd.d
#ls -la /var/lib/ldap
#ls -la /etc/ldap/slapd.d
#ls -la /var/lib

slapd -h 'ldap:/// ldapi:/// ldaps:///' -g openldap -u openldap -F /etc/ldap/slapd.d -d -1 &
 
# just keep this script running
while [[ true ]]; do
    sleep 1
done
