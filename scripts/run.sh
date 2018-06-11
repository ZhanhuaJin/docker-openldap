#!/bin/bash
 
# start 1
/usr/sbin/apachectl -D FOREGROUND &
# start 2
slapd -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d -d stats &
 
# just keep this script running
while [[ true ]]; do
    sleep 1
done
