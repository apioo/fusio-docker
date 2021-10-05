<?php

const MAX_TRY = 4;
const WAIT = 30;

$domain = getenv('FUSIO_DOMAIN');
$email = getenv('FUSIO_BACKEND_EMAIL');

echo 'Try to obtain SSL cert for ' . $domain . "\n";

$count = 1;
$success = false;
while ($count <= MAX_TRY) {
    sleep(WAIT * $count);

    exec('certbot --apache -d ' . $domain . ' --agree-tos -m ' . $email, $output, $exitCode);
    if ($exitCode === 0) {
        echo 'Obtained SSL cert for ' . $domain . "\n";
        break;
    } else {
        echo 'Could not obtain cert for domain ' . $domain . "\n";
        echo implode("\n", $output) . "\n";
    }

    $count++;
}

// remove file
unlink(__FILE__);
