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
  "apiVersion": "5.0.3.0",
  "title": "Fusio",
  "categories": [
    "authorization",
    "system",
    "consumer",
    "backend",
    "default"
  ],
  "scopes": [
    "default",
    "todo"
  ],
  "apps": {
    "fusio": "http://api.fusio.cloud/apps/fusio"
  },
  "links": [
    {
      "href": "http://api.fusio.cloud/",
      "rel": "root"
    },
    {
      "href": "http://api.fusio.cloud/system/export/openapi/*/*",
      "rel": "openapi"
    },
    {
      "href": "http://api.fusio.cloud/system/doc",
      "rel": "documentation"
    },
    {
      "href": "http://api.fusio.cloud/system/route",
      "rel": "route"
    },
    {
      "href": "http://api.fusio.cloud/system/health",
      "rel": "health"
    },
    {
      "href": "http://api.fusio.cloud/system/jsonrpc",
      "rel": "jsonrpc"
    },
    {
      "href": "http://api.fusio.cloud/authorization/token",
      "rel": "oauth2"
    },
    {
      "href": "http://api.fusio.cloud/authorization/whoami",
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
