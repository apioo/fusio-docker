#!/bin/bash

# wait for mysql server
while ! mysqladmin ping -h"$FUSIO_DB_HOST" --silent; do
    sleep 1
done

# install fusio
/usr/bin/php /var/www/html/fusio/bin/fusio system:check install
exitCode=$?
if [ $exitCode -ne 0 ]; then
    /usr/bin/php /var/www/html/fusio/bin/fusio install

    # adjust js apps url
    sed -i 's#\${FUSIO_URL}#'"$FUSIO_URL"'/#g' /var/www/html/fusio/public/*
fi

# add initial backend user
/usr/bin/php /var/www/html/fusio/bin/fusio system:check user
exitCode=$?
if [ $exitCode -ne 0 ]; then
    /usr/bin/php /var/www/html/fusio/bin/fusio user:add --status=1 --username="$FUSIO_BACKEND_USER" --email="$FUSIO_BACKEND_EMAIL" --password="$FUSIO_BACKEND_PW"
fi

# start apache
source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND
