<?php

namespace Api;

use App\Tests\HttpTestCase;

/**
 * SpecificationTest
 *
 * @author  Christoph Kappestein <christoph.kappestein@gmail.com>
 * @license http://www.apache.org/licenses/LICENSE-2.0
 * @link    http://phpsx.org
 */
class SpecificationTest extends HttpTestCase
{
    public function testGetBackend()
    {
        $response = $this->sendRequest('/system/generator/spec-typeapi?filter=backend', 'GET');

        $this->assertEquals(200, $response->getStatusCode());
    }

    public function testGetConsumer()
    {
        $response = $this->sendRequest('/system/generator/spec-typeapi?filter=consumer', 'GET');

        $this->assertEquals(200, $response->getStatusCode());
    }
}
