<?php

$DOMAIN="__DOMAIN__";

// resolve ip for domain
$ip = resolveIp($DOMAIN);
if (empty($ip)) {
    file_put_contents('/home/ssl.log', 'Could not resolve IP for ' . $DOMAIN);
    exit(1);
}

$response = file_get_contents('http://' . $DOMAIN . '/system/health');
if (empty($response)) {
    file_put_contents('/home/ssl.log', 'The domain ' . $DOMAIN . ' is not reachable');
    exit(1);
}

// check that the response is valid
$data = \json_decode($response);
if (!$data instanceof stdClass) {
    file_put_contents('/home/ssl.log', 'The domain ' . $DOMAIN . ' returned an invalid response');
    exit(1);
}

// check that the system is healthy
$healthy = $data->healthy ?? false;
if ($healthy !== true) {
    file_put_contents('/home/ssl.log', 'The domain ' . $DOMAIN . ' is unhealthy');
    exit(1);
}

// register cert for domain
exec('certbot --apache -d ' . $DOMAIN, $output, $exitCode);
if ($exitCode !== 0) {
    file_put_contents('/home/ssl.log', implode("\n", $output));
    exit(1);
}

// remove ssl-cron on success
unlink('/etc/cron.d/ssl');


function resolveIp(string $domain): ?string
{
    $records = dns_get_record($domain, DNS_A | DNS_AAAA);
    foreach ($records as $row) {
        if ($row['type'] === 'A') {
            return $row['ip'];
        } elseif ($row['type'] === 'AAAA') {
            return $row['ip'];
        }
    }

    return null;
}
