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
  "apiVersion": "5.2.3.0",
  "title": "Fusio",
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
    "fusio": "http://api.fusio.cloud:8080/apps/fusio"
    "developer": "http://api.fusio.cloud:8080/apps/developer"
    "documentation": "http://api.fusio.cloud:8080/apps/documentation"
    "swagger-ui": "http://api.fusio.cloud:8080/apps/swagger-ui"
  },
  "links": [
    {
      "href": "http://api.fusio.cloud:8080/",
      "rel": "root"
    },
    {
      "href": "http://api.fusio.cloud:8080/system/export/openapi/*/*",
      "rel": "openapi"
    },
    {
      "href": "http://api.fusio.cloud:8080/system/doc",
      "rel": "documentation"
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
      "href": "http://api.fusio.cloud:8080/system/jsonrpc",
      "rel": "jsonrpc"
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
