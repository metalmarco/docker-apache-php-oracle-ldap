FROM debian:jessie

MAINTAINER Marco Venezia <marco.venezia@skytv.it>

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get -y install git

# Install Apache2 / PHP 5.6 & Co.
RUN apt-get -y install apache2 php5 libapache2-mod-php5 php5-dev php-pear php5-curl php5-ldap curl libaio1

# Install the Oracle Instant Client
ADD oracle/oracle-instantclient12.1-basic_12.1.0.2.0-2_amd64.deb /tmp
ADD oracle/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb /tmp
ADD oracle/oracle-instantclient12.1-sqlplus_12.1.0.2.0-2_amd64.deb /tmp
RUN dpkg -i /tmp/oracle-instantclient12.1-basic_12.1.0.2.0-2_amd64.deb
RUN dpkg -i /tmp/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb
RUN dpkg -i /tmp/oracle-instantclient12.1-sqlplus_12.1.0.2.0-2_amd64.deb
RUN rm -rf /tmp/oracle-instantclient12.1-*.deb

# Set up the Oracle environment variables
ENV LD_LIBRARY_PATH /usr/lib/oracle/12.1/client64/lib/
ENV ORACLE_HOME /usr/lib/oracle/12.1/client64/lib/

# Install the OCI8 PHP extension
RUN echo 'instantclient,/usr/lib/oracle/12.1/client64/lib' | pecl install -f oci8-2.0.8
RUN echo "extension=oci8.so" > /etc/php5/apache2/conf.d/30-oci8.ini

# Enable Apache2 modules
RUN a2enmod rewrite


# Source installation
ARG GIT_USERNAME
ARG GIT_PASSWORD
ARG GIT_SOURCE_REPO
RUN cd /var/www/html
RUN [ -z "$GIT_USERNAME" ] || git clone https://$GIT_USERNAME:$GIT_PASSWORD@$GIT_SOURCE_REPO


# Set up the Apache2 environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# Run Apache2 in Foreground
CMD /usr/sbin/apache2 -D FOREGROUND
