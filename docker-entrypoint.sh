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

# execute migrations in case the dir exists
if [ -d src/Migrations ]; then
    for dir in src/Migrations; do
        php bin/fusio migration:up-to-date --connection=$dir
        exitCode=$?
        if [ $exitCode -ne 0 ]; then
            php bin/fusio migration:migrate --connection=$dir --no-interaction
        fi
    done
fi

# add initial backend user
php bin/fusio system:check user
exitCode=$?
if [ $exitCode -ne 0 ]; then
    php bin/fusio adduser --role=1 --username="$FUSIO_BACKEND_USER" --email="$FUSIO_BACKEND_EMAIL" --password="$FUSIO_BACKEND_PW"
fi

# install backend app
php bin/fusio marketplace:install fusio
php bin/fusio marketplace:install developer
php bin/fusio marketplace:install documentation
php bin/fusio marketplace:install swagger-ui

# deploy
php bin/fusio login --username="$FUSIO_BACKEND_USER" --password="$FUSIO_BACKEND_PW"

# flush cron file
php bin/fusio system:cronjob_flush

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

# start generate ssl script
php /home/generate-ssl.php &

# create env file for cron
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export FUSIO" > /home/env.sh
chmod +x /home/env.sh

# remove existing pid
rm -f /var/run/apache2/apache2.pid

# start apache
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND -D FUSIO_DOMAIN=$FUSIO_DOMAIN
