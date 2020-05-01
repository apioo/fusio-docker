<?php

namespace App\Tests\Api;

use App\Tests\HttpTestCase;

/**
 * TodoTest
 *
 * @author  Christoph Kappestein <christoph.kappestein@gmail.com>
 * @license http://www.apache.org/licenses/LICENSE-2.0
 * @link    http://phpsx.org
 */
class TodoTest extends HttpTestCase
{
    public function testGet()
    {
        $response = $this->sendRequest('/todo', 'GET');

        $actual = (string) $response->getBody();
        $actual = preg_replace('/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/', '0000-00-00 00:00:00', $actual);
        $expect = file_get_contents(__DIR__ . '/resource/todo.json');

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertJsonStringEqualsJsonString($expect, $actual);
    }
}
