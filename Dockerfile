FROM php:7.4-apache
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="1.0"
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
ENV COMPOSER_SHA256 "24faa5bc807e399f32e9a21a33fbb5b0686df9c8850efabe2c047c2ccfb9f9cc"

ENV APACHE_DOCUMENT_ROOT /var/www/html/fusio/public

# install default packages
RUN apt-get update && apt-get -y install \
    wget \
    git \
    unzip \
    memcached

# install php extensions
RUN docker-php-ext-install \
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

RUN docker-php-ext-enable \
    memcached \
    mongodb

# install composer
RUN wget -O /usr/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar
RUN echo "${COMPOSER_SHA256} */usr/bin/composer" | sha256sum -c -
RUN chmod +x /usr/bin/composer

# install fusio
RUN wget -O /var/www/html/fusio.zip "https://github.com/apioo/fusio/archive/${FUSIO_VERSION}.zip"
RUN cd /var/www/html && unzip fusio.zip
RUN cd /var/www/html && mv fusio-${FUSIO_VERSION} fusio
RUN cd /var/www/html/fusio && /usr/bin/composer install
COPY ./fusio /var/www/html/fusio
RUN chown -R www-data: /var/www/html/fusio
RUN chmod +x /var/www/html/fusio/bin/fusio

# remove files
RUN rm /var/www/html/fusio/public/install.php

# apache config
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite
COPY ./etc/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf

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

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
