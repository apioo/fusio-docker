<?php

namespace App\Tests;

use GuzzleHttp\Client;
use Psr\Http\Message\ResponseInterface;

/**
 * HttpTestCase
 *
 * @author  Christoph Kappestein <christoph.kappestein@gmail.com>
 * @license http://www.apache.org/licenses/LICENSE-2.0
 * @link    http://phpsx.org
 */
class HttpTestCase extends \PHPUnit_Framework_TestCase
{
    /**
     * @var Client
     */
    private static $httpClient;

    /**
     * Sends an request to the system and returns the http response
     *
     * @param string $uri
     * @param string $method
     * @param array $headers
     * @param string $body
     * @return ResponseInterface
     */
    protected function sendRequest($uri, $method, $headers = array(), $body = null)
    {
        return self::getHttpClient()->request($method, $uri, [
            'headers' => $headers,
            'body'    => $body,
        ]);
    }

    /**
     * @return Client
     */
    private function getHttpClient()
    {
        if (!self::$httpClient) {
            self::$httpClient = new Client([
                'base_uri' => 'http://localhost'
            ]);
        }

        return self::$httpClient;
    }
}
