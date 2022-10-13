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
    for dir in src/Migrations/*; do
        connection=$(basename $dir)
        php bin/fusio migration:up-to-date --connection=$connection
        exitCode=$?
        if [ $exitCode -ne 0 ]; then
            php bin/fusio migration:migrate --connection=$connection --no-interaction
        fi
    done
fi

# add initial backend user
php bin/fusio system:check user
exitCode=$?
if [ $exitCode -ne 0 ]; then
    php bin/fusio adduser --role=1 --username="$FUSIO_BACKEND_USER" --email="$FUSIO_BACKEND_EMAIL" --password="$FUSIO_BACKEND_PW"
fi

# replace env
php bin/fusio marketplace:env fusio
php bin/fusio marketplace:env developer
php bin/fusio marketplace:env documentation
php bin/fusio marketplace:env swagger-ui

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

# create env script
echo '#!/bin/bash' > env.sh
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export FUSIO" >> env.sh
chown www-data: env.sh
chmod +x env.sh

popd

# start cron
service cron start

# remove existing pid
rm -f /var/run/apache2/apache2.pid

# start apache
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND -D FUSIO_DOMAIN=$FUSIO_DOMAIN
