#!/bin/bash

# wait for mysql server
/wait-for-it.sh "$FUSIO_DB_HOST:3306" -t 60

pushd /var/www/html/fusio

# install fusio
php bin/fusio migration:up-to-date
exitCode=$?
if [ $exitCode -ne 0 ]; then
    # migrate fusio
    php bin/fusio migration:migrate --no-interaction
fi

# install app
php bin/fusio migration:up-to-date --connection=System
exitCode=$?
if [ $exitCode -ne 0 ]; then
    # migrate app
    php bin/fusio migration:migrate --connection=System --no-interaction
fi

# add initial backend user
php bin/fusio system:check user
exitCode=$?
if [ $exitCode -ne 0 ]; then
    php bin/fusio adduser --role=1 --username="$FUSIO_BACKEND_USER" --email="$FUSIO_BACKEND_EMAIL" --password="$FUSIO_BACKEND_PW"

    # register adapters
    php bin/fusio system:register -y "Fusio\Adapter\Amqp\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Beanstalk\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Elasticsearch\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Memcache\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Mongodb\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Redis\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Smtp\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Soap\Adapter"

    # install backend app
    php bin/fusio marketplace:install fusio
fi

# deploy
php bin/fusio login --username="$FUSIO_BACKEND_USER" --password="$FUSIO_BACKEND_PW"
php bin/fusio deploy
php bin/fusio logout

popd

# remove existing pid
rm -f /var/run/apache2/apache2.pid

# start apache
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND -D FUSIO_DOMAIN=$FUSIO_DOMAIN
