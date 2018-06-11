#FROM phusion/baseimage:0.9.16
# Use baseimage-docker's init system.
#CMD ["/sbin/my_init"]
#FROM osixia/openldap:1.2.1

#ENV DEBIAN_FRONTEND noninteractive

# Install Apache2, PHP and LTB ssp
#RUN apt-get update && apt-get install -y apache2 php5 php5-mcrypt php5-ldap && apt-get clean
#RUN curl -L https://ltb-project.org/archives/self-service-password_1.0-2_all.deb > self-service-password.deb && dpkg -i self-service-password.deb ; rm -f self-service-password.deb
#RUN apt-get update && apt-get install -y curl apache2 php7.0 php7.0-mcrypt php7.0-ldap libapache2-mod-php7.0 php7.0-mbstring php7.0-xml php7.0-zip && apt-get clean
#RUN curl -L https://ltb-project.org/archives/self-service-password_1.2-1_all.deb > self-service-password.deb && dpkg -i self-service-password.deb ; rm -f self-service-password.deb

# Configure self-service-password site
#RUN ln -s ../../mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
#RUN a2dissite 000-default && a2ensite self-service-password

# This is where configuration goes
#ADD assets/config.inc.php /usr/share/self-service-password/conf/config.inc.php

# Start Apache2 as runit service
#RUN mkdir /etc/service
#RUN mkdir /etc/service/apache2
#ADD assets/apache2.sh /etc/service/apache2/run

#EXPOSE 80

#CMD /usr/sbin/apachectl -D FOREGROUND
#CMD sh -c /etc/service/apache2/run 
#RUN sh /usr/sbin/apache2ctl -k start

FROM  ubuntu:xenial

MAINTAINER Larry Cai "larry.caiyu@gmail.com"

# install slapd in noninteractive mode
RUN apt-get update && \
	echo 'slapd/root_password password password' | debconf-set-selections && \
    echo 'slapd/root_password_again password password' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils curl apache2 php7.0 php7.0-mcrypt php7.0-ldap libapache2-mod-php7.0 php7.0-mbstring php7.0-xml php7.0-zip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#RUN apt-get update && apt-get install -y curl apache2 php7.0 php7.0-mcrypt php7.0-ldap libapache2-mod-php7.0 php7.0-mbstring php7.0-xml php7.0-zip && apt-get clean
RUN curl -L https://ltb-project.org/archives/self-service-password_1.2-1_all.deb > self-service-password.deb && dpkg -i self-service-password.deb ; rm -f self-service-password.deb

# Configure self-service-password site
#RUN ln -s ../../mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
RUN a2dissite 000-default && a2ensite self-service-password

# This is where configuration goes
ADD assets/config.inc.php /usr/share/self-service-password/conf/config.inc.php

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

VOLUME /var/lib/ldap
VOLUME /etc/ldap/slapd.d

EXPOSE 80
EXPOSE 389

#CMD slapd -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d -d stats
#CMD /usr/sbin/apachectl -D FOREGROUND
ADD scripts/run.sh /root/run.sh
RUN chmod +x /root/run.sh
CMD /root/run.sh
