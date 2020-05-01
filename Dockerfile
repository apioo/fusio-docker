FROM ubuntu:bionic
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="1.0"
LABEL description="Fusio API management"

# env
ENV FUSIO_PROJECT_KEY "42eec18ffdbffc9fda6110dcc705d6ce"
ENV FUSIO_HOST "acme.com"
ENV FUSIO_URL "http://acme.com"
ENV FUSIO_APPS_URL "http://apps.acme.com"
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

ENV FUSIO_VERSION "master"

ENV COMPOSER_VERSION "1.10.5"
ENV COMPOSER_SHA256 "d5f3fddd0be28a5fc9bf2634a06f51bc9bd581fabda93fee7ca8ca781ae43129"

# install default packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    wget \
    git \
    unzip \
    apache2 \
    memcached \
    libapache2-mod-php7.2 \
    php7.2

# install php7 extensions
RUN apt-get update && apt-get -y install \
    php7.2-mysql \
    php7.2-pgsql \
    php7.2-sqlite3 \
    php7.2-simplexml \
    php7.2-dom \
    php7.2-bcmath \
    php7.2-curl \
    php7.2-zip \
    php7.2-mbstring \
    php7.2-intl \
    php7.2-xml \
    php7.2-curl \
    php7.2-gd \
    php7.2-soap \
    php-memcached \
    php-mongodb

# install composer
RUN wget -O /usr/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar
RUN echo "${COMPOSER_SHA256} */usr/bin/composer" | sha256sum -c -
RUN chmod +x /usr/bin/composer

# install fusio
RUN wget -O /var/www/html/fusio.zip "https://github.com/apioo/fusio/archive/${FUSIO_VERSION}.zip"
RUN cd /var/www/html && unzip fusio.zip
RUN cd /var/www/html && mv fusio-${FUSIO_VERSION} fusio
RUN cd /var/www/html/fusio && /usr/bin/composer install
COPY ./fusio/resources /var/www/html/fusio/resources
COPY ./fusio/src /var/www/html/fusio/src
COPY ./fusio/.env /var/www/html/fusio/.env
COPY ./fusio/.fusio.yml /var/www/html/fusio/.fusio.yml
COPY ./fusio/configuration.php /var/www/html/fusio/configuration.php
COPY ./fusio/container.php /var/www/html/fusio/container.php
RUN chown -R www-data: /var/www/html/fusio
RUN chmod +x /var/www/html/fusio/bin/fusio

# remove install file
RUN rm /var/www/html/fusio/public/install.php
RUN rm /var/www/html/fusio/public/.htaccess

# apache config
COPY ./etc/apache2/apache2.conf /etc/apache2/apache2.conf
COPY ./etc/apache2/ports.conf /etc/apache2/ports.conf
COPY ./etc/apache2/conf-available/other-vhosts-access-log.conf /etc/apache2/conf-available/other-vhosts-access-log.conf
RUN touch /etc/apache2/sites-available/000-fusio.conf
RUN chmod a+rwx /etc/apache2/sites-available/000-fusio.conf
RUN mkdir -p /run/apache2/
RUN chmod a+rwx /run/apache2/

# php config
COPY ./etc/php/99-custom.ini /etc/php/7.2/apache2/conf.d/99-custom.ini
COPY ./etc/php/99-custom.ini /etc/php/7.2/cli/conf.d/99-custom.ini

# install additional connectors
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-amqp
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-beanstalk
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-elasticsearch
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-memcache
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-mongodb
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-redis
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-smtp
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-soap

# apache config
RUN a2enmod rewrite
RUN a2dissite 000-default
RUN a2ensite 000-fusio

# install cron
RUN touch /etc/cron.d/fusio
RUN chmod a+rwx /etc/cron.d/fusio

# mount volumes
VOLUME /var/www/html/fusio/apps
VOLUME /var/www/html/fusio/public

# start memcache
RUN service memcached start

# healthcheck
HEALTHCHECK CMD curl -f "${FUSIO_URL}/export/health" || exit 1;

# add entrypoint
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
