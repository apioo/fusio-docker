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

# add initial backend user
php bin/fusio system:check user
exitCode=$?
if [ $exitCode -ne 0 ]; then
    php bin/fusio adduser --role=1 --username="$FUSIO_BACKEND_USER" --email="$FUSIO_BACKEND_EMAIL" --password="$FUSIO_BACKEND_PW"
fi

# replace env
php bin/fusio marketplace:env fusio
php bin/fusio marketplace:env developer
php bin/fusio marketplace:env redoc

# deploy
php bin/fusio login --username="$FUSIO_BACKEND_USER" --password="$FUSIO_BACKEND_PW"

php bin/fusio deploy
php bin/fusio logout

# create env script
echo '#!/bin/bash' > env.sh
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export FUSIO" >> env.sh
chown www-data: env.sh
chmod +x env.sh

popd

# chown
chown -R www-data: /var/www/html/fusio/cache
chown -R www-data: /var/www/html/fusio/log

# start cron
service cron start

# remove existing pid
rm -f /var/run/apache2/apache2.pid

# start apache
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND
