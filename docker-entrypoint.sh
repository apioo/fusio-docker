#!/bin/bash

# wait for mysql server
while ! mysqladmin ping -h"$FUSIO_DB_HOST" --silent; do
    sleep 1
done

pushd /var/www/html/fusio

# install fusio
php bin/fusio system:check install
exitCode=$?
if [ $exitCode -ne 0 ]; then
    php bin/fusio install

    # adjust js apps url
    find public/ -type f -exec sed -i 's#\${FUSIO_URL}#'"$FUSIO_URL"'#g' {} \;

    # register adapters
    php bin/fusio system:register -y "Fusio\Adapter\Amqp\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Beanstalk\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Elasticsearch\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Memcache\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Mongodb\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Redis\Adapter"
    php bin/fusio system:register -y "Fusio\Adapter\Soap\Adapter"
fi

# execute install in case we need to upgade
php bin/fusio system:check upgrade
exitCode=$?
if [ $exitCode -ne 0 ]; then
    php bin/fusio install
fi

# add initial backend user
php bin/fusio system:check user
exitCode=$?
if [ $exitCode -ne 0 ]; then
    php bin/fusio user:add --status=1 --username="$FUSIO_BACKEND_USER" --email="$FUSIO_BACKEND_EMAIL" --password="$FUSIO_BACKEND_PW"
fi

# deploy
php bin/fusio deploy

popd

# start apache
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND
