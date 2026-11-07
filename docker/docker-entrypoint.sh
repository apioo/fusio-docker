#!/bin/bash

pushd /var/www/html/fusio

# wait for external services
php bin/fusio system:wait_for

# install fusio
php bin/fusio migration:up-to-date
if [ $? -ne 0 ]; then
    # migrate fusio
    php bin/fusio migration:migrate --no-interaction
fi

# add initial backend user
php bin/fusio system:check user
if [ $? -ne 0 ]; then
    php bin/fusio adduser --role=1 --username="$FUSIO_BACKEND_USER" --email="$FUSIO_BACKEND_EMAIL" --password="$FUSIO_BACKEND_PW"
fi

# replace env
php bin/fusio marketplace:env -

# login
php bin/fusio login --username="$FUSIO_BACKEND_USER" --password="$FUSIO_BACKEND_PW"

# configure worker
setup_worker() {
    php bin/fusio connection:detail "$1"
    if [ $? -ne 0 ]; then
        echo "{\"name\":\"$1\",\"class\":\"Fusio.Adapter.Worker.Connection.Worker\",\"config\":{\"url\":\"http://$2\"}}" > /tmp/connection.json
        php bin/fusio connection:create /tmp/connection.json
    else
        echo "{\"name\":\"$1\",\"class\":\"Fusio.Adapter.Worker.Connection.Worker\",\"config\":{\"url\":\"http://$2\"}}" > /tmp/connection.json
        php bin/fusio connection:update "$1" /tmp/connection.json
    fi
}

if [ ! -z "$FUSIO_WORKER_JAVA" ]; then
    setup_worker "Java-Worker" $FUSIO_WORKER_JAVA
fi

if [ ! -z "$FUSIO_WORKER_JAVASCRIPT" ]; then
    setup_worker "Javascript-Worker" $FUSIO_WORKER_JAVASCRIPT
fi

if [ ! -z "$FUSIO_WORKER_PHP" ]; then
    setup_worker "PHP-Worker" $FUSIO_WORKER_PHP
fi

if [ ! -z "$FUSIO_WORKER_PYTHON" ]; then
    setup_worker "Python-Worker" $FUSIO_WORKER_PYTHON
fi

# run deploy
php bin/fusio deploy

# logout
php bin/fusio logout

# create env script
echo '#!/bin/bash' > env.sh
declare -px | sed 's/^declare -x /export /g' | grep -E "^export FUSIO" >> env.sh
chown www-data: env.sh
chmod +x env.sh

popd

# chown
chown -R www-data: /var/www/html/fusio/cache
chown -R www-data: /var/www/html/fusio/log

# start cron
service cron start

# start supervisor
supervisord

# we start all worker and ignore any errors at startup
supervisorctl start all || true

# remove existing pid
rm -f /var/run/apache2/apache2.pid

# start apache
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND
