#!/bin/bash
pushd /var/www/html/fusio
source ./env.sh
/usr/local/bin/php bin/fusio system:$1
popd
