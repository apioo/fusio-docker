FROM ubuntu:xenial
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="1.0"

# env
ENV FUSIO_PROJECT_KEY 42eec18ffdbffc9fda6110dcc705d6ce
ENV FUSIO_URL http://localhost
ENV FUSIO_DB_USER fusio
ENV FUSIO_DB_PW test123
ENV FUSIO_DB_HOST localhost
ENV FUSIO_DB_NAME fusio

ENV FUSIO_BACKEND_USER test
ENV FUSIO_BACKEND_EMAIL test@test.com
ENV FUSIO_BACKEND_PW test1234!

ENV COMPOSER_VERSION 1.2.2
ENV COMPOSER_SHA1 c1c20037f990604f4b90d4827563934590e174f7

ENV FUSIO_VERSION 0.4.1
ENV FUSIO_SHA1 ec7f8736468a5fe0ffe5e9399a84018a274b9e83

# install default packages
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor memcached wget git unzip apache2 libapache2-mod-php7.0 php7.0 mysql-server

# install php7 extensions
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.0-mysql php7.0-simplexml php7.0-dom php7.0-curl php7.0-zip php7.0-mbstring php7.0-intl php7.0-xml php7.0-curl php7.0-gd php-memcached

# install php7 v8 extension
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common python-software-properties
RUN add-apt-repository -y ppa:ondrej/php
RUN add-apt-repository -y ppa:pinepain/php
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-v8

# install composer
RUN wget -O /usr/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar
RUN echo "${COMPOSER_SHA1} */usr/bin/composer" | sha1sum -c -
RUN chmod +x /usr/bin/composer

# install fusio
RUN mkdir /var/www/html/fusio
RUN wget -O /var/www/html/fusio/fusio.zip https://github.com/apioo/fusio/releases/download/v${FUSIO_VERSION}/fusio_${FUSIO_VERSION}.zip
RUN echo "${FUSIO_SHA1} */var/www/html/fusio/fusio.zip" | sha1sum -c -
RUN cd /var/www/html/fusio && unzip fusio.zip
ADD ./fusio/configuration.php /var/www/html/fusio/configuration.php
RUN chown -R www-data: /var/www/html/fusio

# apache config
ADD ./apache/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# php config
ADD ./php/99-custom.ini /etc/php/7.0/apache2/conf.d/99-custom.ini

# mysql config
# @see https://github.com/docker-library/mysql/blob/master/5.7/Dockerfile
RUN rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && chmod 777 /var/run/mysqld
ADD ./mysql/my.cnf /etc/mysql/conf.d/my.cnf

# supervisord config
ADD ./supervisord/start-apache2.sh /start-apache2.sh
ADD ./supervisord/start-memcached.sh /start-memcached.sh
ADD ./supervisord/start-mysqld.sh /start-mysqld.sh
ADD ./supervisord/apache2.conf /etc/supervisor/conf.d/apache2.conf
ADD ./supervisord/memcached.conf /etc/supervisor/conf.d/memcached.conf
ADD ./supervisord/mysqld.conf /etc/supervisor/conf.d/mysqld.conf
RUN chmod +x /start-apache2.sh
RUN chmod +x /start-memcached.sh
RUN chmod +x /start-mysqld.sh

# add init script
ADD ./run.sh /run.sh
RUN chmod +x /run.sh

# mount volumes
VOLUME /var/log
VOLUME /var/lib/mysql
VOLUME /var/www/html/fusio

EXPOSE 80
CMD ["/run.sh"]
