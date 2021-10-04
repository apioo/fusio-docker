#!/bin/bash

pushd /var/www/html/fusio

# wait for external services
php bin/fusio system:wait_for

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

# create app database
if [ $exitCode -ne 0 ]; then
    mysql --host="$FUSIO_DB_HOST" --user=root --password="$FUSIO_DB_PW" --execute="CREATE USER 'app'@'%' IDENTIFIED BY '$FUSIO_DB_PW';"
    mysql --host="$FUSIO_DB_HOST" --user=root --password="$FUSIO_DB_PW" --execute="CREATE DATABASE IF NOT EXISTS app;"
    mysql --host="$FUSIO_DB_HOST" --user=root --password="$FUSIO_DB_PW" --execute="GRANT ALL PRIVILEGES ON app.* TO 'app'@'%';"
    mysql --host="$FUSIO_DB_HOST" --user=root --password="$FUSIO_DB_PW" --execute="FLUSH PRIVILEGES;"
    echo '{"name": "App", "class": "Fusio\\Adapter\\Sql\\Connection\\Sql", "config": {"type": "pdo_mysql", "host": "'$FUSIO_DB_HOST'", "username": "app", "password": "'$FUSIO_DB_PW'", "database": "app"}}' > connection.json
    php bin/fusio connection:create connection.json
    rm connection.json
fi

php bin/fusio deploy
php bin/fusio logout

popd

# remove existing pid
rm -f /var/run/apache2/apache2.pid

# start apache
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND -D FUSIO_DOMAIN=$FUSIO_DOMAIN
