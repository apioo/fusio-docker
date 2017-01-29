FROM ubuntu:xenial
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="1.0"

# env
ENV FUSIO_PROJECT_KEY "42eec18ffdbffc9fda6110dcc705d6ce"
ENV FUSIO_URL "http://localhost"
ENV FUSIO_DB_USER "fusio"
ENV FUSIO_DB_PW "61ad6c605975"
ENV FUSIO_DB_HOST "localhost"
ENV FUSIO_DB_PORT "3306"
ENV FUSIO_DB_NAME "fusio"

ENV FUSIO_MEMCACHE_HOST "localhost"
ENV FUSIO_MEMCACHE_PORT "11211"

ENV FUSIO_BACKEND_USER "demo"
ENV FUSIO_BACKEND_EMAIL "demo@fusio-project.org"
ENV FUSIO_BACKEND_PW "c6!337d2ef$c"

ENV FUSIO_VERSION "0.6.5"
ENV FUSIO_SHA1 "18523461fdb42f1b840078a5a1dfb17dc7a1dc40"

ENV COMPOSER_VERSION "1.2.2"
ENV COMPOSER_SHA1 "c1c20037f990604f4b90d4827563934590e174f7"

# install default packages
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install memcached wget git unzip apache2 libapache2-mod-php7.0 php7.0 mysql-server

# install php7 extensions
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.0-mysql php7.0-pgsql php7.0-simplexml php7.0-dom php7.0-curl php7.0-zip php7.0-mbstring php7.0-intl php7.0-xml php7.0-curl php7.0-gd php-memcached

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
RUN wget -O /var/www/html/fusio/fusio.zip "https://github.com/apioo/fusio/releases/download/v${FUSIO_VERSION}/fusio_${FUSIO_VERSION}.zip"
RUN echo "${FUSIO_SHA1} */var/www/html/fusio/fusio.zip" | sha1sum -c -
RUN cd /var/www/html/fusio && unzip fusio.zip
ADD ./fusio/configuration.php /var/www/html/fusio/configuration.php
RUN chown -R www-data: /var/www/html/fusio
RUN chmod +x /var/www/html/fusio/bin/fusio

# install additional connectors
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-amqp
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-beanstalk
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-elasticsearch
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-memcache
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-mongodb
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-neo4j
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-redis
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-soap

# apache config
RUN a2enmod rewrite

# php config
ADD ./php/99-custom.ini /etc/php/7.0/apache2/conf.d/99-custom.ini

# mount volumes
VOLUME /var/log/apache2
VOLUME /etc/apache2/sites-available
VOLUME /var/www/html/fusio/src
VOLUME /var/www/html/fusio/public

# add entrypoint
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
