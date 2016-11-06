#!/bin/bash

VOLUME_HOME="/var/lib/mysql"
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    /usr/bin/mysqld_safe

    mysql -uroot -e "CREATE DATABASE fusio"
    mysql -uroot -e "CREATE USER 'fusio'@'localhost' IDENTIFIED BY '$FUSIO_DB_PW'"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON fusio.* TO 'fusio'@'localhost' WITH GRANT OPTION"
    mysql -uroot -e "FLUSH PRIVILEGES"

    /var/www/html/fusio/bin/fusio install
    #    /var/www/html/fusio/bin/fusio adduser --status 1 --username ${FUSIO_BACKEND_USER} --email ${FUSIO_BACKEND_EMAIL} --password ${FUSIO_BACKEND_PW}

    mysqladmin -uroot shutdown
fi

exec supervisord -n
