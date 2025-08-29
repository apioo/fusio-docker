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
  "apiVersion": "8.6.0.0",
  "title": "Fusio",
  "description": "Self-Hosted API Management for Builders.",
  "paymentCurrency": "EUR",
  "categories": [
    "authorization",
    "backend",
    "consumer",
    "default",
    "system"
  ],
  "scopes": [
    "default"
  ],
  "links": [
    {
      "rel": "root",
      "href": "http://api.fusio.cloud:8080/"
    },
    {
      "rel": "openapi",
      "href": "http://api.fusio.cloud:8080/system/generator/spec-openapi"
    },
    {
      "rel": "typeapi",
      "href": "http://api.fusio.cloud:8080/system/generator/spec-typeapi"
    },
    {
      "rel": "route",
      "href": "http://api.fusio.cloud:8080/system/route"
    },
    {
      "rel": "health",
      "href": "http://api.fusio.cloud:8080/system/health"
    },
    {
      "rel": "oauth2",
      "href": "http://api.fusio.cloud:8080/authorization/token"
    },
    {
      "rel": "whoami",
      "href": "http://api.fusio.cloud:8080/authorization/whoami"
    },
    {
      "rel": "api-catalog",
      "href": "http://api.fusio.cloud:8080/.well-known/api-catalog"
    },
    {
      "rel": "oauth-authorization-server",
      "href": "http://api.fusio.cloud:8080/.well-known/oauth-authorization-server"
    },
    {
      "rel": "oauth-protected-resource",
      "href": "http://api.fusio.cloud:8080/.well-known/oauth-protected-resource"
    },
    {
      "rel": "security",
      "href": "http://api.fusio.cloud:8080/.well-known/security.txt"
    },
    {
      "rel": "about",
      "href": "https://www.fusio-project.org"
    }
  ]
}
JSON;

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertJsonStringEqualsJsonString($expect, $actual);
    }
}
