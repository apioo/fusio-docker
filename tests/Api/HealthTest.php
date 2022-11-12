<?php

namespace App\Tests\Api;

use App\Tests\HttpTestCase;

/**
 * HealthTest
 *
 * @author  Christoph Kappestein <christoph.kappestein@gmail.com>
 * @license http://www.apache.org/licenses/LICENSE-2.0
 * @link    http://phpsx.org
 */
class HealthTest extends HttpTestCase
{
    public function testGet()
    {
        $response = $this->sendRequest('/system/health', 'GET');

        $actual = (string) $response->getBody();
        $expect = <<<JSON
{
    "healthy": true,
    "checks": {
        "System": {
            "healthy": true
        }
    }
}
JSON;

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertJsonStringEqualsJsonString($expect, $actual);
    }
}
