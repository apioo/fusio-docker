<?php

$domain = getenv('FUSIO_DOMAIN');
if (empty($domain)) {
    file_put_contents('/home/ssl.log', 'Environment variable FUSIO_DOMAIN not available');
    exit(1);
}

$host = getenv('FUSIO_HOST');
if (empty($host)) {
    file_put_contents('/home/ssl.log', 'Environment variable FUSIO_HOST not available');
    exit(1);
}

// resolve ip for domain
$ip = resolveIp($domain);
if (empty($ip)) {
    file_put_contents('/home/ssl.log', 'Could not resolve IP for ' . $domain);
    exit(1);
}

$response = file_get_contents('http://' . $host . '/system/health');
if (empty($response)) {
    file_put_contents('/home/ssl.log', 'The host ' . $host . ' is not reachable');
    exit(1);
}

// check that the response is valid
$data = \json_decode($response);
if (!$data instanceof stdClass) {
    file_put_contents('/home/ssl.log', 'The host ' . $host . ' returned an invalid response');
    exit(1);
}

// check that the system is healthy
$healthy = $data->healthy ?? false;
if ($healthy !== true) {
    file_put_contents('/home/ssl.log', 'The host ' . $host . ' is unhealthy');
    exit(1);
}

// register cert for domain
exec('certbot --apache -d ' . $domain, $output, $exitCode);
if ($exitCode !== 0) {
    file_put_contents('/home/ssl.log', 'Could not obtain cert for domain ' . $domain . "\n" . implode("\n", $output));
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
