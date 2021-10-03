<?php

$domain = getenv('FUSIO_DOMAIN');
if (empty($domain)) {
    file_put_contents('/home/ssl.log', 'Environment variable FUSIO_DOMAIN not available');
    exit(1);
}

// register cert for domain
$email = getenv('FUSIO_BACKEND_EMAIL');
exec('certbot --apache -d ' . $domain . ' --agree-tos -m ' . $email, $output, $exitCode);
if ($exitCode !== 0) {
    file_put_contents('/home/ssl.log', 'Could not obtain cert for domain ' . $domain . "\n" . implode("\n", $output));
    exit(1);
}

// remove ssl-cron on success
unlink('/etc/cron.d/ssl');
