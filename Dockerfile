FROM php:8.4-apache
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="6.0.0"
LABEL description="Fusio API management"

# env
ENV FUSIO_PROJECT_KEY="42eec18ffdbffc9fda6110dcc705d6ce"
ENV FUSIO_ENV="prod"
ENV FUSIO_DEBUG="false"
ENV FUSIO_CONNECTION="pdo-mysql://fusio:61ad6c605975@localhost/fusio"

ENV FUSIO_BACKEND_USER="demo"
ENV FUSIO_BACKEND_EMAIL="demo@fusio-project.org"
ENV FUSIO_BACKEND_PW="75dafcb12c4f"

ENV FUSIO_MAILER="native://default"
ENV FUSIO_MESSENGER="doctrine://default"
ENV FUSIO_URL=""
ENV FUSIO_APPS_URL=""
ENV FUSIO_MAIL_SENDER=""
ENV FUSIO_TRUSTED_IP_HEADER=""
ENV FUSIO_TENANT_ID=""
ENV FUSIO_MARKETPLACE="off"

ENV FUSIO_WORKER_JAVA=""
ENV FUSIO_WORKER_JAVASCRIPT=""
ENV FUSIO_WORKER_PHP=""
ENV FUSIO_WORKER_PYTHON=""

ARG FUSIO_VERSION="6.0.0"
ARG FUSIO_APP_BACKEND="6.0.0"
ARG FUSIO_APP_DEVELOPER="6.0.0"
ARG FUSIO_APP_ACCOUNT="2.0.0"
ARG FUSIO_APP_REDOC="1.0.4"

ARG COMPOSER_VERSION="2.8.6"
ARG COMPOSER_SHA256="becc28b909d2cca563e7caee1e488063312af36b1f2e31db64f417723b8c4026"

# install default packages
RUN apt-get update && apt-get -y install \
    wget \
    git \
    unzip \
    cron \
    sudo \
    supervisor \
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
    libicu-dev \
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
    opcache \
    intl \
    xml \
    gd \
    soap \
    sockets

# install pecl
RUN pecl install memcache-8.2 \
    && pecl install mongodb-2.1.2

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
COPY ./fusio /var/www/html/fusio
RUN cd /var/www/html/fusio && /usr/bin/composer install --no-dev
RUN cd /var/www/html/fusio && /usr/bin/composer dump-autoload --no-dev --classmap-authoritative
RUN chmod +x /var/www/html/fusio/bin/fusio

# apache config
RUN rm /etc/apache2/sites-available/*.conf
RUN rm /etc/apache2/sites-enabled/*.conf
COPY ./apache/fusio.conf /etc/apache2/sites-available/fusio.conf
RUN a2enmod rewrite
RUN a2ensite fusio

# supervisor config
COPY supervisor/fusio.conf /etc/supervisor/conf.d/fusio.conf

# php config
RUN mv "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"
COPY ./php/fusio.ini "${PHP_INI_DIR}/conf.d/fusio.ini"

RUN cd /var/www/html/fusio

# install apps
RUN mkdir /var/www/html/fusio/public/apps/fusio
RUN wget -O /var/www/html/fusio/public/apps/fusio/fusio.zip "https://github.com/apioo/fusio-apps-backend/releases/download/v${FUSIO_APP_BACKEND}/fusio.zip"
RUN cd /var/www/html/fusio/public/apps/fusio && unzip fusio.zip
RUN rm /var/www/html/fusio/public/apps/fusio/fusio.zip

RUN mkdir /var/www/html/fusio/public/apps/developer
RUN wget -O /var/www/html/fusio/public/apps/developer/developer.zip "https://github.com/apioo/fusio-apps-developer/releases/download/v${FUSIO_APP_DEVELOPER}/developer.zip"
RUN cd /var/www/html/fusio/public/apps/developer && unzip developer.zip
RUN rm /var/www/html/fusio/public/apps/developer/developer.zip

RUN mkdir /var/www/html/fusio/public/apps/account
RUN wget -O /var/www/html/fusio/public/apps/account/account.zip "https://github.com/apioo/fusio-apps-account/releases/download/v${FUSIO_APP_ACCOUNT}/account.zip"
RUN cd /var/www/html/fusio/public/apps/account && unzip account.zip
RUN rm /var/www/html/fusio/public/apps/account/account.zip

RUN wget -O /var/www/html/fusio/public/apps/redoc.zip "https://github.com/apioo/fusio-apps-redoc/archive/refs/tags/v${FUSIO_APP_REDOC}.zip"
RUN cd /var/www/html/fusio/public/apps && unzip redoc.zip
RUN rm /var/www/html/fusio/public/apps/redoc.zip
RUN cd /var/www/html/fusio/public/apps && mv fusio-apps-redoc-${FUSIO_APP_REDOC} redoc

# clean up files
RUN rm /var/www/html/fusio/public/install.php
RUN rm -r /tmp/pear

# chown
RUN chown -R www-data: /var/www/html/fusio

# create cron
RUN echo "" > /etc/cron.d/fusio
RUN echo "* * * * * www-data /var/www/html/fusio/run_cron.sh cronjob" >> /etc/cron.d/fusio
RUN echo "0 0 1 * * www-data /var/www/html/fusio/run_cron.sh log_rotate" >> /etc/cron.d/fusio
RUN echo "0 0 1 * * www-data /var/www/html/fusio/run_cron.sh clean" >> /etc/cron.d/fusio
RUN chmod 0644 /etc/cron.d/fusio
RUN chmod +x /var/www/html/fusio/run_cron.sh

# add entrypoint
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
