FROM php:7.4-apache
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="2.0"
LABEL description="Fusio API management"

# env
ENV FUSIO_PROJECT_KEY "42eec18ffdbffc9fda6110dcc705d6ce"
ENV FUSIO_HOST "acme.com"
ENV FUSIO_URL "http://${FUSIO_HOST}"
ENV FUSIO_APPS_URL "${FUSIO_URL}/apps"
ENV FUSIO_ENV "prod"
ENV FUSIO_DB_NAME "fusio"
ENV FUSIO_DB_USER "fusio"
ENV FUSIO_DB_PW "61ad6c605975"
ENV FUSIO_DB_HOST "localhost"

ENV FUSIO_BACKEND_USER "demo"
ENV FUSIO_BACKEND_EMAIL "demo@fusio-project.org"
ENV FUSIO_BACKEND_PW "75dafcb12c4f"

ENV PROVIDER_FACEBOOK_KEY ""
ENV PROVIDER_FACEBOOK_SECRET ""
ENV PROVIDER_GOOGLE_KEY ""
ENV PROVIDER_GOOGLE_SECRET ""
ENV PROVIDER_GITHUB_KEY ""
ENV PROVIDER_GITHUB_SECRET ""
ENV RECAPTCHA_KEY ""
ENV RECAPTCHA_SECRET ""

ENV FUSIO_MEMCACHE_HOST "localhost"
ENV FUSIO_MEMCACHE_PORT "11211"

ENV FUSIO_VERSION "2.0.0"

ENV COMPOSER_VERSION "2.0.9"
ENV COMPOSER_SHA256 "8e91344a5ca2fc0fb583c50f195a1f36918908561c4ea3d6f01a4ef01c3b8560"

ENV APACHE_DOCUMENT_ROOT /var/www/html/fusio/public

# install default packages
RUN apt-get update && apt-get -y install \
    wget \
    git \
    unzip \
    cron \
    memcached \
    libpq-dev \
    libxml2-dev \
    libcurl3-dev \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    libmemcached-dev

# install php extensions
RUN docker-php-ext-install \
    pgsql \
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
RUN pecl install memcache-4.0.5.2 \
    && pecl install mongodb-1.9.0

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
COPY ./apache/fusio.conf /etc/apache2/conf-available/fusio.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN sed -ri -e 's!#Include conf-available/serve-cgi-bin.conf!Include conf-available/fusio.conf!g' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# php config
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

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

# install cron
RUN touch /etc/cron.d/fusio
RUN chmod a+rwx /etc/cron.d/fusio

# mount volumes
VOLUME /var/www/html/fusio/public

# start memcache
RUN service memcached start

# add entrypoint
COPY ./wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# clean up files
RUN rm /var/www/html/fusio.zip
RUN rm -r /tmp/pear

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
