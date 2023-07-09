<?php

namespace App\Tests;

use GuzzleHttp\Client;
use PHPUnit\Framework\TestCase;
use Psr\Http\Message\ResponseInterface;

/**
 * HttpTestCase
 *
 * @author  Christoph Kappestein <christoph.kappestein@gmail.com>
 * @license http://www.apache.org/licenses/LICENSE-2.0
 * @link    http://phpsx.org
 */
class HttpTestCase extends TestCase
{
    private static ?Client $httpClient = null;

    /**
     * Sends a request to the system and returns the http response
     */
    protected function sendRequest(string $uri, string $method, array $headers = [], ?string $body = null): ResponseInterface
    {
        return self::getHttpClient()->request($method, $uri, [
            'headers' => $headers,
            'body'    => $body,
        ]);
    }

    private function getHttpClient(): Client
    {
        if (!self::$httpClient) {
            self::$httpClient = new Client([
                'base_uri' => 'http://api.fusio.cloud:8080'
            ]);
        }

        return self::$httpClient;
    }
}
