#!/bin/bash

# wait for mysql server
while ! mysqladmin ping -h"$FUSIO_DB_HOST" --silent; do
    sleep 1
done

# install fusio
/usr/bin/php /var/www/html/fusio/bin/fusio install

# add initial backend user
/usr/bin/php /var/www/html/fusio/bin/fusio user:add --status=1 --username="$FUSIO_BACKEND_USER" --email="$FUSIO_BACKEND_EMAIL" --password="$FUSIO_BACKEND_PW"

# start supervisor
exec supervisord -n
