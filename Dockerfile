FROM ubuntu:zesty
MAINTAINER Christoph Kappestein <christoph.kappestein@apioo.de>
LABEL version="1.0"

# env
ENV FUSIO_PROJECT_KEY "42eec18ffdbffc9fda6110dcc705d6ce"
ENV FUSIO_URL "http://localhost"
ENV FUSIO_ENV "prod"
ENV FUSIO_DB_NAME "fusio"
ENV FUSIO_DB_USER "fusio"
ENV FUSIO_DB_PW "61ad6c605975"
ENV FUSIO_DB_HOST "localhost"

ENV FUSIO_BACKEND_USER "demo"
ENV FUSIO_BACKEND_EMAIL "demo@fusio-project.org"
ENV FUSIO_BACKEND_PW "75dafcb12c4f"

ENV PROVIDER_FACEBOOK_SECRET ""
ENV PROVIDER_GOOGLE_SECRET ""
ENV PROVIDER_GITHUB_SECRET ""
ENV RECAPTCHA_SECRET ""

ENV FUSIO_MEMCACHE_HOST "localhost"
ENV FUSIO_MEMCACHE_PORT "11211"

ENV FUSIO_VERSION "master"

ENV COMPOSER_VERSION "1.5.2"
ENV COMPOSER_SHA1 "6dc307027b69892191dca036dcc64bb02dd74ab2"

# install default packages
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget git unzip apache2 memcached libapache2-mod-php7.0 php7.0 mysql-client

# install php7 extensions
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.0-mysql php7.0-pgsql php7.0-sqlite3 php7.0-simplexml php7.0-dom php7.0-bcmath php7.0-curl php7.0-zip php7.0-mbstring php7.0-intl php7.0-xml php7.0-curl php7.0-gd php7.0-soap php-memcached

# install libs
COPY ./lib/libv8 /usr/lib
COPY ./lib/php/20151012 /usr/lib/php/20151012

# install composer
RUN wget -O /usr/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar
RUN echo "${COMPOSER_SHA1} */usr/bin/composer" | sha1sum -c -
RUN chmod +x /usr/bin/composer

# install fusio
RUN mkdir /var/www/html/fusio
RUN wget -O /var/www/html/fusio/fusio.zip "https://github.com/apioo/fusio/archive/${FUSIO_VERSION}.zip"
RUN cd /var/www/html/fusio && unzip fusio.zip
RUN cd /var/www/html/fusio && /usr/bin/composer install
COPY ./fusio/public /var/www/html/fusio/public
COPY ./fusio/resources /var/www/html/fusio/resources
COPY ./fusio/src /var/www/html/fusio/src
COPY ./fusio/configuration.php /var/www/html/fusio/configuration.php
COPY ./fusio/container.php /var/www/html/fusio/container.php
RUN chown -R www-data: /var/www/html/fusio
RUN chmod +x /var/www/html/fusio/bin/fusio

# apache config
COPY ./etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

# php config
COPY ./etc/php/99-custom.ini /etc/php/7.0/apache2/conf.d/99-custom.ini
COPY ./etc/php/99-custom.ini /etc/php/7.0/cli/conf.d/99-custom.ini

# install additional connectors
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-amqp
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-beanstalk
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-elasticsearch
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-memcache
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-mongodb
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-redis
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-smtp
RUN cd /var/www/html/fusio && /usr/bin/composer require fusio/adapter-soap

# adjust js apps url
RUN find /var/www/html/fusio/public/ -type f -exec sed -i 's#\${FUSIO_URL}#'"$FUSIO_URL"'#g' {} \;

# apache config
RUN a2enmod rewrite

# install cron
RUN touch /etc/cron.d/fusio
RUN chown -R www-data: /etc/cron.d/fusio

# start memcache
RUN service memcached start

# add entrypoint
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
