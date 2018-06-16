FROM  ubuntu:xenial

MAINTAINER Zhanhua Jin "jinzhanhua@gmail.com"

ENV SSP_VER=1.2
ENV LAM_VER=6.3
ENV LAM_USER=lam
ENV LAM_DIR=/usr/share/ldap-account-manager

# install slapd in noninteractive mode
RUN apt-get update && \
	echo 'slapd/root_password password password' | debconf-set-selections && \
    echo 'slapd/root_password_again password password' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils curl bzip2 apache2 php7.0 php7.0-mcrypt php7.0-ldap libapache2-mod-php7.0 php7.0-mbstring php7.0-xml php7.0-zip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#RUN apt-get update && apt-get install -y curl apache2 php7.0 php7.0-mcrypt php7.0-ldap libapache2-mod-php7.0 php7.0-mbstring php7.0-xml php7.0-zip && apt-get clean
RUN curl -L https://ltb-project.org/archives/self-service-password_${SSP_VER}-1_all.deb > self-service-password.deb && dpkg -i self-service-password.deb ; rm -f self-service-password.deb
RUN useradd -M -d ${LAM_DIR} ${LAM_USER} \
	&& cd /tmp \
	&& curl -L https://sourceforge.net/projects/lam/files/LAM/${LAM_VER}/ldap-account-manager-${LAM_VER}.tar.bz2/download  > ldap-account-manager.tar.bz2 \
	&& tar -jxf ldap-account-manager.tar.bz2 \
	&& rm -f ldap-account-manager.tar.bz2 \
	&& mkdir ${LAM_DIR} \
	&& cp -R ldap-account-manager-${LAM_VER}/* ${LAM_DIR} \
	&& rm -rf /tmp/* \
	&& cp ${LAM_DIR}/config/config.cfg.sample ${LAM_DIR}/config/config.cfg \
	&& chown -R ${LAM_USER}:${LAM_USER} ${LAM_DIR} \
	&& chmod og+rwx ${LAM_DIR}/sess ${LAM_DIR}/tmp \
	&& chmod 777 ${LAM_DIR}/config \
	&& chmod 666 ${LAM_DIR}/config/config.cfg

# Configure self-service-password site
#RUN ln -s ../../mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini

# This is where configuration goes
ADD config/ssp/config.inc.php /usr/share/self-service-password/conf/config.inc.php

ADD config/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
#ADD config/apache/self-service-password.conf /etc/apache2/sites-available/self-service-password.conf
#ADD config/apache/ldap-account-manager.conf /etc/apache2/sites-available/ldap-account-manager.conf

#DEBUG
#RUN ls -la /usr/share/self-service-password
#RUN ls -la ${LAM_DIR}
#RUN ls -la /etc/apache2/sites-available
#RUN more /etc/apache2/sites-available/000-default.conf
#RUN more /etc/apache2/sites-available/self-service-password.conf

#RUN a2dissite 000-default
#RUN a2ensite self-service-password
#RUN a2ensite ldap-account-manager

# Start Apache2 as runit service
#CMD /usr/sbin/apachectl -k start


#ADD files /ldap

#RUN service slapd start ;\
#    cd /ldap &&\
#	ldapadd -Y EXTERNAL -H ldapi:/// -f back.ldif &&\
#	ldapadd -Y EXTERNAL -H ldapi:/// -f sssvlv_load.ldif &&\
#    ldapadd -Y EXTERNAL -H ldapi:/// -f sssvlv_config.ldif &&\
#    ldapadd -x -D cn=admin,dc=openstack,dc=org -w password -c -f front.ldif &&\
#    ldapadd -x -D cn=admin,dc=openstack,dc=org -w password -c -f more.ldif

# LDAP
VOLUME /var/lib/ldap
VOLUME /etc/ldap/slapd.d

# SSP
#VOLUME /usr/share/self-service-password/conf/config.inc.php


EXPOSE 80
EXPOSE 389

#CMD slapd -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d -d stats
#CMD /usr/sbin/apachectl -D FOREGROUND
ADD scripts/run.sh /root/run.sh
RUN chmod +x /root/run.sh
CMD /root/run.sh
