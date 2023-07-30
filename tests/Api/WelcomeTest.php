<?php

namespace App\Tests\Api;

use App\Tests\HttpTestCase;

/**
 * WelcomeTest
 *
 * @author  Christoph Kappestein <christoph.kappestein@gmail.com>
 * @license http://www.apache.org/licenses/LICENSE-2.0
 * @link    http://phpsx.org
 */
class WelcomeTest extends HttpTestCase
{
    public function testGet()
    {
        $response = $this->sendRequest('/', 'GET');

        $actual = (string) $response->getBody();
        $actual = preg_replace('/[0-9a-fA-F]{40}/', '[hash]', $actual);

        $expect = <<<JSON
{
  "apiVersion": "7.1.4.0",
  "title": "Fusio",
  "paymentCurrency": "EUR",
  "categories": [
    "authorization",
    "system",
    "consumer",
    "backend",
    "default"
  ],
  "scopes": [
    "default"
  ],
  "apps": {
    "fusio": "http://api.fusio.cloud:8080/apps/fusio",
    "developer": "http://api.fusio.cloud:8080/apps/developer",
    "redoc": "http://api.fusio.cloud:8080/apps/redoc"
  },
  "links": [
    {
      "href": "http://api.fusio.cloud:8080/",
      "rel": "root"
    },
    {
      "href": "http://api.fusio.cloud:8080/system/generator/spec-openapi",
      "rel": "openapi"
    },
    {
      "href": "http://api.fusio.cloud:8080/system/generator/spec-typeapi",
      "rel": "typeapi"
    },
    {
      "href": "http://api.fusio.cloud:8080/system/route",
      "rel": "route"
    },
    {
      "href": "http://api.fusio.cloud:8080/system/health",
      "rel": "health"
    },
    {
      "href": "http://api.fusio.cloud:8080/authorization/token",
      "rel": "oauth2"
    },
    {
      "href": "http://api.fusio.cloud:8080/authorization/whoami",
      "rel": "whoami"
    },
    {
      "href": "https://www.fusio-project.org",
      "rel": "about"
    }
  ]
}
JSON;

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertJsonStringEqualsJsonString($expect, $actual);
    }
}
