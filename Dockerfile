FROM php:8.0-apache
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="3.3.0"
LABEL description="Fusio API management"

# env
ENV FUSIO_PROJECT_KEY="42eec18ffdbffc9fda6110dcc705d6ce"
ENV FUSIO_DOMAIN="api.fusio.cloud"
ENV FUSIO_HOST="api.fusio.cloud"
ENV FUSIO_URL="http://api.fusio.cloud"
ENV FUSIO_APPS_URL="http://api.fusio.cloud/apps"
ENV FUSIO_ENV="prod"
ENV FUSIO_DB_NAME="fusio"
ENV FUSIO_DB_USER="fusio"
ENV FUSIO_DB_PW="61ad6c605975"
ENV FUSIO_DB_HOST="localhost"

ENV FUSIO_BACKEND_USER="demo"
ENV FUSIO_BACKEND_EMAIL="demo@fusio-project.org"
ENV FUSIO_BACKEND_PW="75dafcb12c4f"

ENV FUSIO_MAILER="native://default"
ENV FUSIO_MAIL_SENDER=""
ENV FUSIO_PHP_SANDBOX="off"
ENV FUSIO_MARKETPLACE="off"
ENV FUSIO_PAYMENT_CURRENCY="EUR"

ENV FUSIO_WORKER_JAVA=""
ENV FUSIO_WORKER_JAVASCRIPT=""
ENV FUSIO_WORKER_PHP=""
ENV FUSIO_WORKER_PYTHON=""

ARG FUSIO_VERSION="3.3.0"
ARG FUSIO_APP_BACKEND="2.0.4"
ARG FUSIO_APP_DEVELOPER="2.0.2"
ARG FUSIO_APP_DOCUMENTATION="1.0.6"
ARG FUSIO_APP_SWAGGERUI="1.0.3"

ARG COMPOSER_VERSION="2.4.2"
ARG COMPOSER_SHA256="8fe98a01050c92cc6812b8ead3bd5b6e0bcdc575ce7a93b242bde497a31d7732"

# install default packages
RUN apt-get update && apt-get -y install \
    wget \
    git \
    unzip \
    cron \
    sudo \
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
    soap \
    sockets

# install pecl
RUN pecl install memcache-8.0 \
    && pecl install mongodb-1.14.1

RUN docker-php-ext-enable \
    memcache \
    mongodb

# install composer
RUN wget -O /usr/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar
RUN echo "${COMPOSER_SHA256} */usr/bin/composer" | sha256sum -c -
RUN chmod +x /usr/bin/composer

# install fusio
RUN mkdir /var/www/html/fusio
RUN wget -O /var/www/html/fusio/fusio.zip "https://github.com/apioo/fusio/releases/download/v${FUSIO_VERSION}/fusio.zip"
RUN cd /var/www/html/fusio && unzip fusio.zip
RUN rm /var/www/html/fusio/fusio.zip
RUN cd /var/www/html/fusio && /usr/bin/composer install
COPY ./fusio /var/www/html/fusio
RUN chmod +x /var/www/html/fusio/bin/fusio

# apache config
RUN rm /etc/apache2/sites-available/*.conf
RUN rm /etc/apache2/sites-enabled/*.conf
COPY ./apache/fusio.conf /etc/apache2/sites-available/fusio.conf
RUN a2enmod rewrite
RUN a2ensite fusio

# php config
RUN mv "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

# install additional connectors
RUN cd /var/www/html/fusio && \
    /usr/bin/composer require fusio/adapter-amqp ^5.0 && \
    /usr/bin/composer require fusio/adapter-beanstalk ^5.0 && \
    /usr/bin/composer require fusio/adapter-elasticsearch ^5.0 && \
    /usr/bin/composer require fusio/adapter-memcache ^5.0 && \
    /usr/bin/composer require fusio/adapter-mongodb ^5.0 && \
    /usr/bin/composer require fusio/adapter-redis ^5.0 && \
    /usr/bin/composer require fusio/adapter-smtp ^5.0 && \
    /usr/bin/composer require fusio/adapter-soap ^5.0 && \
    /usr/bin/composer require fusio/adapter-stripe ^5.0 && \
    /usr/bin/composer require symfony/sendgrid-mailer ^6.0 && \
    /usr/bin/composer require symfony/http-client ^6.0

# install apps
RUN mkdir /var/www/html/fusio/public/apps/fusio
RUN wget -O /var/www/html/fusio/public/apps/fusio/fusio.zip "https://github.com/apioo/fusio-apps-backend/releases/download/v${FUSIO_APP_BACKEND}/fusio.zip"
RUN cd /var/www/html/fusio/public/apps/fusio && unzip fusio.zip
RUN rm /var/www/html/fusio/public/apps/fusio/fusio.zip

RUN mkdir /var/www/html/fusio/public/apps/developer
RUN wget -O /var/www/html/fusio/public/apps/developer/developer.zip "https://github.com/apioo/fusio-apps-developer/releases/download/v${FUSIO_APP_DEVELOPER}/developer.zip"
RUN cd /var/www/html/fusio/public/apps/developer && unzip developer.zip
RUN rm /var/www/html/fusio/public/apps/developer/developer.zip

RUN wget -O /var/www/html/fusio/public/apps/documentation.zip "https://github.com/apioo/fusio-apps-documentation/archive/v${FUSIO_APP_DOCUMENTATION}.zip"
RUN cd /var/www/html/fusio/public/apps && unzip documentation.zip
RUN rm /var/www/html/fusio/public/apps/documentation.zip
RUN cd /var/www/html/fusio/public/apps && mv fusio-apps-documentation-${FUSIO_APP_DOCUMENTATION} documentation

RUN wget -O /var/www/html/fusio/public/apps/swaggerui.zip "https://github.com/apioo/fusio-apps-swaggerui/archive/v${FUSIO_APP_SWAGGERUI}.zip"
RUN cd /var/www/html/fusio/public/apps && unzip swaggerui.zip
RUN rm /var/www/html/fusio/public/apps/swaggerui.zip
RUN cd /var/www/html/fusio/public/apps && mv fusio-apps-swaggerui-${FUSIO_APP_SWAGGERUI} swagger-ui

# clean up files
RUN rm /var/www/html/fusio/public/install.php
RUN rm -r /tmp/pear

# chown
RUN chown -R www-data: /var/www/html/fusio

# create cron
RUN echo "" > /etc/cron.d/fusio
RUN echo "* * * * * www-data cd /var/www/html/fusio && source env.sh && /usr/local/bin/php bin/fusio cronjob > /tmp/cronjob.log 2>&1" >> /etc/cron.d/fusio
RUN echo "0 0 1 * * www-data cd /var/www/html/fusio && source env.sh && /usr/local/bin/php bin/fusio system:log_rotate > /tmp/log_rotate.log 2>&1" >> /etc/cron.d/fusio
RUN echo "0 0 1 * * www-data cd /var/www/html/fusio && source env.sh && /usr/local/bin/php bin/fusio system:clean > /tmp/clean.log 2>&1" >> /etc/cron.d/fusio
RUN chmod 0644 /etc/cron.d/fusio

# add entrypoint
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
