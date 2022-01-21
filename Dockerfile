FROM php:8.0-apache
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="2.1.8"
LABEL description="Fusio API management"

# env
ENV FUSIO_PROJECT_KEY "42eec18ffdbffc9fda6110dcc705d6ce"
ENV FUSIO_DOMAIN "api.fusio.cloud"
ENV FUSIO_HOST "api.fusio.cloud"
ENV FUSIO_URL "http://api.fusio.cloud"
ENV FUSIO_APPS_URL "http://api.fusio.cloud/apps"
ENV FUSIO_ENV "prod"
ENV FUSIO_DB_NAME "fusio"
ENV FUSIO_DB_USER "fusio"
ENV FUSIO_DB_PW "61ad6c605975"
ENV FUSIO_DB_HOST "localhost"

ENV FUSIO_BACKEND_USER "demo"
ENV FUSIO_BACKEND_EMAIL "demo@fusio-project.org"
ENV FUSIO_BACKEND_PW "75dafcb12c4f"

ENV FUSIO_MEMCACHE_HOST "localhost"
ENV FUSIO_MEMCACHE_PORT "11211"

ENV FUSIO_VERSION "2.1.8"
ENV FUSIO_CERTBOT "0"

ENV COMPOSER_VERSION "2.1.9"
ENV COMPOSER_SHA256 "4d00b70e146c17d663ad2f9a21ebb4c9d52b021b1ac15f648b4d371c04d648ba"

# install default packages
RUN apt-get update && apt-get -y install \
    wget \
    git \
    unzip \
    cron \
    certbot \
    python3-certbot-apache \
    memcached \
    default-mysql-client \
    libpq-dev \
    libxml2-dev \
    libcurl3-dev \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    libmemcached-dev \
    openssl \
    libssl-dev \
    libcurl4-openssl-dev

# install php extensions
RUN docker-php-ext-install \
    pgsql \
    mysqli \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    simplexml \
    dom \
    bcmath \
    curl \
    zip \
    mbstring \
    intl \
    xml \
    gd \
    soap

# install pecl
RUN pecl install memcache-8.0 \
    && pecl install mongodb-1.12.0

RUN docker-php-ext-enable \
    memcache \
    mongodb

# install composer
RUN wget -O /usr/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar
RUN echo "${COMPOSER_SHA256} */usr/bin/composer" | sha256sum -c -
RUN chmod +x /usr/bin/composer

# install fusio
RUN wget -O /var/www/html/fusio.zip "https://github.com/apioo/fusio/archive/v${FUSIO_VERSION}.zip"
RUN cd /var/www/html && unzip fusio.zip
RUN cd /var/www/html && mv fusio-${FUSIO_VERSION} fusio
RUN cd /var/www/html/fusio && /usr/bin/composer install
COPY ./fusio /var/www/html/fusio
RUN chown -R www-data: /var/www/html/fusio
RUN chmod +x /var/www/html/fusio/bin/fusio

# remove files
RUN rm /var/www/html/fusio/public/install.php

# apache config
RUN rm /etc/apache2/sites-available/*.conf
RUN rm /etc/apache2/sites-enabled/*.conf
COPY ./apache/fusio.conf /etc/apache2/sites-available/fusio.conf
RUN a2enmod rewrite
RUN a2ensite fusio

# ssl script
COPY ./apache/generate-ssl.php /home/generate-ssl.php
RUN chmod +x /home/generate-ssl.php

# php config
RUN mv "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

# install additional connectors
RUN cd /var/www/html/fusio && \
    /usr/bin/composer require fusio/adapter-amqp ^4.0 && \
    /usr/bin/composer require fusio/adapter-beanstalk ^4.0 && \
    /usr/bin/composer require fusio/adapter-elasticsearch ^4.0 && \
    /usr/bin/composer require fusio/adapter-memcache ^4.0 && \
    /usr/bin/composer require fusio/adapter-mongodb ^4.0 && \
    /usr/bin/composer require fusio/adapter-redis ^4.0 && \
    /usr/bin/composer require fusio/adapter-smtp ^4.0 && \
    /usr/bin/composer require fusio/adapter-soap ^4.0

# clean up files
RUN rm /var/www/html/fusio.zip
RUN rm -r /tmp/pear

# mount volumes
VOLUME /var/www/html/fusio/public

# start cron
RUN touch /etc/cron.d/fusio
RUN chmod 0777 /etc/cron.d/fusio
RUN service cron start

# start memcache
RUN service memcached start

# add entrypoint
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/docker-entrypoint.sh"]
