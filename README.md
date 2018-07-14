# docker-openldap
A docker image to run OpenLDAP and LDAP Account Manager and Self Service Password.
Based on Ubuntu 16.04 container.

Before start 

1 You have existing OpenLDAP data and copy them to your docker host. OpenLDAP mount host directories as LDAP database. Assuming you have a LDAP database on your docker host in the directory /data/slapd/database and the corresponding LDAP config files on your docker host in the directory /data/slapd/config 
2 You should create certifications for SSL connection with OpenLDAP and Apache WebServer. Assuming you have a certifications on your docker host in the directory /data/ssl and certification files named ca.crt server.crt server.key. 
3 Get config files for LDAP Account Manager. In Dockerfile, LAM_VER=6.3, mean version of LDAP Account Manager is 6.3, download correspond compressed file from https://sourceforge.net/projects/lam/files/LAM/6.3/ldap-account-manager-6.3.tar.bz2
Extracting compressed file, copy whole config directory to docker host directory /data/lam 
and copy config.cfg.sample to config.cfg
4 Get config file for Self Service Password. In Dockerfile, SSP_VER=1.3, mean version of Self Service Password is 1.3, download correspond compressed file from https://ltb-project.org/archives/ltb-project-self-service-password-1.3.tar.gz
Extracting compressed file, copy config.inc.php to docker host directory /data/ssp and edit LDAP section of this file to match your LDAP configuration.

Run docker

docker run --name ldap --rm -p 80:80 -p 389:389 -p 443:443 -p 636:636 --volume /data/ssl:/etc/ssl/private --volume /data/slapd/data:/var/lib/ldap --volume /data/slapd/config:/etc/ldap/slapd.d -v /data/ssp/config.inc.php:/usr/share/self-service-password/conf/config.inc.php --volume /data/lam/config:/usr/share/ldap-account-manager/config jinzhanhua/openldap:1.0

Enable SSL for OpenLDAP
docker exec ldap ldapmodify -Y EXTERNAL -H ldapi:/// -f /usr/share/openldap/setssl.ldif
After SSL enabled, please restart docker container

Backup
Backup whole directory on docker host

TODO
Add replication for OpenLDAP
