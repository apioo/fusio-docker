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
        $expect = <<<JSON
{
    "message": "Congratulations the installation of Fusio was successful",
    "apiVersion": "3.0.0",
    "links": [
        {
            "rel": "about",
            "name": "http:\/\/fusio-project.org"
        }
    ]
}
JSON;

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertJsonStringEqualsJsonString($expect, $actual);
    }
}
