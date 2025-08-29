#!/bin/bash
pushd /var/www/html/fusio
./env.sh
/usr/local/bin/php bin/fusio system:$1
popd
