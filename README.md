# docker-openldap
A docker image to run OpenLDAP and LDAP Account Manager and Self Service Password.
Based on Ubuntu 16.04 container.

## Before start 
### Generate own certificate
On Ubuntu, install GnuTLS tools
<pre><code>apt install gnutls-bin</code></pre>
Run certtool generate ca private key
<pre><code>certtool --generate-privkey > ca.key</code></pre>
Create a template file ca.info to define the CA certificate<br>
<pre><code>cn = your domain name
ca
cert_signing_key</code></pre>
Create the CA self-signed certificate using the CA private key and the template
<pre><code>certtool --generate-self-signed --load-privkey ca.key --template ca.info --outfile ca.crt</code></pre>
Create server private key and certificate<br>
<pre><code>certtool --generate-privkey --bits 2048 --outfile server.key</code></pre>
Create the template for server certificate named server.info. 
<pre><code>organization = your organization name
cn = your hostname.your domain name
tls_www_server
encryption_key
signing_key
expiration_days = 3650</code></pre>
Create the server certificate.
<pre><code>certtool --generate-certificate --load-privkey server.key --load-ca-certificate ca.crt --load-ca-privkey ca.key --template server.info --outfile server.crt</code></pre>
Three certificate files is used for docker
<pre><code>ca.crt           CA certificate
server.key       Server certificate
server.crt       Server private key
</code></pre>
### Copy existing OpenLDAP data
You have existing OpenLDAP data and copy them to your docker host. OpenLDAP mount host directories as LDAP database. Assuming you have a LDAP database on your docker host in the directory /data/slapd/database and the corresponding LDAP config files on your docker host in the directory /data/slapd/config<br>
### Copy generated certifications
The certification was used for SSL connection both OpenLDAP and Apache WebServer. Assuming you have a certifications on your docker host in the directory /data/ssl and certification files named ca.crt server.crt server.key<br> 
### Copy LDAP Account Manager config files
In Dockerfile, LAM_VER=6.3, mean version of LDAP Account Manager is 6.3, download correspond compressed file from https://sourceforge.net/projects/lam/files/LAM/6.3/ldap-account-manager-6.3.tar.bz2
Extracting compressed file, copy whole config directory to docker host directory /data/lam 
and copy config.cfg.sample to config.cfg<br>
### Copy Self Service Password config file
In Dockerfile, SSP_VER=1.3, mean version of Self Service Password is 1.3, download correspond compressed file from https://ltb-project.org/archives/ltb-project-self-service-password-1.3.tar.gz
Extracting compressed file, copy config.inc.php to docker host directory /data/ssp<br>
Edit LDAP section of this file to match your LDAP configuration.

## Run docker
<pre><code>docker run --name ldap --rm -p 80:80 -p 389:389 -p 443:443 -p 636:636 --volume /data/ssl:/etc/ssl/private --volume /data/slapd/database:/var/lib/ldap --volume /data/slapd/config:/etc/ldap/slapd.d -v /data/ssp/config.inc.php:/usr/share/self-service-password/conf/config.inc.php --volume /data/lam/config:/usr/share/ldap-account-manager/config jinzhanhua/openldap:1.0</code></pre>

## Enable SSL for OpenLDAP
<pre><code>docker exec ldap ldapmodify -Y EXTERNAL -H ldapi:/// -f /usr/share/openldap/setssl.ldif<br>After SSL enabled, please restart docker container</code></pre>

## Run LDAP Account Manager
Open browser, enter https://localhost/lam 

## Run Self Service Password
Open browser, enter https://localhost/ssp

## Backup
Backup whole directory /data on docker host
## Tips
### Directories and files permission on docker host
#### Files used by certification
ca.crt<br>
server.crt<br>
server.key<br>
Should has read permission for OpenLDAP and Apache<br>
<pre><code>sudo chmod 644 ca.crt server.crt server.key</code></pre>
#### Folders contain data of OpenLDAP
/data/slapd/database<br>
/data/slapd/config<br>
Should belong to same user and group who run OpenLDAP within docker<br>
<pre><code>sudo chmod -R 105 /data/slapd/database
sudo chmod -R 105 /data/slapd/config
sudo chgrp -R 106 /data/slapd/database
sudo chgrp -R 106 /data/slapd/config</code></pre>
#### Folder contain data of LDAP Account Manager
/data/lam<br>
LDAP Account Manager should has write permission on this folder<br>
<pre><code>sudo chmod 777 /data/lam</code></pre> 
## TODO
Add replication for OpenLDAP
