#!/bin/bash
pushd /var/www/html/fusio
source env.sh
/usr/local/bin/php bin/fusio system:$1 > /tmp/$1.log 2>&1
popd
