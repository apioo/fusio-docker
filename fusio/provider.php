<?php

/*
This file contains classes which extend the functionality of Fusio. If you
register a new adapter and this adapter provides such a class, Fusio will
automatically add the class to this file. You can also manually add a new
class. The following list contains an explanation of each extension point:

- action
  Contains all action classes which are available at the backend. If a class is
  registered here the user can select this action. The class must implement the
  interface: Fusio\Engine\ActionInterface
- connection
  Contains all connection classes which are available at the backend. If a class
  is registered here the user can select this connection. The class must
  implement the interface: Fusio\Engine\ConnectionInterface
- payment
  Contains all available payment provider. Through a payment provider it is
  possible to charge for points which can be required for specific routes. The
  class must implement the interface: Fusio\Engine\Payment\ProviderInterface
- user
  Contains all available user provider. Through a user provider a user can
  authenticate with a remote provider i.e. Google. The class must implement the
  interface: Fusio\Engine\User\ProviderInterface
- routes
  Contains all available route provider. A provider can automatically create
  multiple schemas, actions and routes under a provided base path. The class
  must implement the interface: Fusio\Engine\Routes\ProviderInterface
*/

return [
    'action' => [
        \Fusio\Adapter\Amqp\Action\AmqpPublish::class,
        \Fusio\Adapter\Beanstalk\Action\BeanstalkPublish::class,
        \Fusio\Adapter\Cli\Action\CliProcessor::class,
        \Fusio\Adapter\Elasticsearch\Action\ElasticsearchDelete::class,
        \Fusio\Adapter\Elasticsearch\Action\ElasticsearchGet::class,
        \Fusio\Adapter\Elasticsearch\Action\ElasticsearchIndex::class,
        \Fusio\Adapter\Elasticsearch\Action\ElasticsearchSearch::class,
        \Fusio\Adapter\Fcgi\Action\FcgiProcessor::class,
        \Fusio\Adapter\File\Action\FileDirectoryIndex::class,
        \Fusio\Adapter\File\Action\FileDirectoryDetail::class,
        \Fusio\Adapter\File\Action\FileProcessor::class,
        \Fusio\Adapter\GraphQL\Action\GraphQLProcessor::class,
        \Fusio\Adapter\Http\Action\HttpComposition::class,
        \Fusio\Adapter\Http\Action\HttpLoadBalancer::class,
        \Fusio\Adapter\Http\Action\HttpProcessor::class,
        \Fusio\Adapter\Mongodb\Action\MongoDeleteOne::class,
        \Fusio\Adapter\Mongodb\Action\MongoFindAll::class,
        \Fusio\Adapter\Mongodb\Action\MongoFindOne::class,
        \Fusio\Adapter\Mongodb\Action\MongoInsertOne::class,
        \Fusio\Adapter\Mongodb\Action\MongoUpdateOne::class,
        \Fusio\Adapter\Php\Action\PhpProcessor::class,
        \Fusio\Adapter\Php\Action\PhpSandbox::class,
        \Fusio\Adapter\Redis\Action\RedisHashDelete::class,
        \Fusio\Adapter\Redis\Action\RedisHashGet::class,
        \Fusio\Adapter\Redis\Action\RedisHashGetAll::class,
        \Fusio\Adapter\Redis\Action\RedisHashSet::class,
        \Fusio\Adapter\Smtp\Action\SmtpSend::class,
        \Fusio\Adapter\Sql\Action\SqlSelectAll::class,
        \Fusio\Adapter\Sql\Action\SqlSelectRow::class,
        \Fusio\Adapter\Sql\Action\SqlInsert::class,
        \Fusio\Adapter\Sql\Action\SqlUpdate::class,
        \Fusio\Adapter\Sql\Action\SqlDelete::class,
        \Fusio\Adapter\Sql\Action\Query\SqlQueryAll::class,
        \Fusio\Adapter\Sql\Action\Query\SqlQueryRow::class,
        \Fusio\Adapter\Util\Action\UtilABTest::class,
        \Fusio\Adapter\Util\Action\UtilCache::class,
        \Fusio\Adapter\Util\Action\UtilJsonPatch::class,
        \Fusio\Adapter\Util\Action\UtilRedirect::class,
        \Fusio\Adapter\Util\Action\UtilStaticResponse::class,
        \Fusio\Impl\Worker\Action\WorkerJava::class,
        \Fusio\Impl\Worker\Action\WorkerJavascript::class,
        \Fusio\Impl\Worker\Action\WorkerPHP::class,
        \Fusio\Impl\Worker\Action\WorkerPython::class,
    ],
    'connection' => [
        \Fusio\Adapter\Amqp\Connection\Amqp::class,
        \Fusio\Adapter\Beanstalk\Connection\Beanstalk::class,
        \Fusio\Adapter\Elasticsearch\Connection\Elasticsearch::class,
        \Fusio\Adapter\GraphQL\Connection\GraphQL::class,
        \Fusio\Adapter\Http\Connection\Http::class,
        \Fusio\Adapter\Memcache\Connection\Memcache::class,
        \Fusio\Adapter\Mongodb\Connection\MongoDB::class,
        \Fusio\Adapter\Redis\Connection\Redis::class,
        \Fusio\Adapter\Smtp\Connection\Smtp::class,
        \Fusio\Adapter\Soap\Connection\Soap::class,
        \Fusio\Adapter\Stripe\Connection\Stripe::class,
        \Fusio\Adapter\Sql\Connection\Sql::class,
        \Fusio\Adapter\Sql\Connection\SqlAdvanced::class,
    ],
    'payment' => [
        \Fusio\Adapter\Stripe\Provider\Stripe::class,
    ],
    'user' => [
        \Fusio\Impl\Provider\User\Facebook::class,
        \Fusio\Impl\Provider\User\Github::class,
        \Fusio\Impl\Provider\User\Google::class,
    ],
    'routes' => [
        \Fusio\Adapter\File\Routes\FileDirectory::class,
        \Fusio\Adapter\Sql\Routes\SqlTable::class,
        \Fusio\Adapter\Mongodb\Routes\MongoCollection::class,
        \Fusio\Adapter\Elasticsearch\Routes\ElasticsearchDocument::class,
        \Fusio\Adapter\Redis\Routes\RedisHash::class,
        \Fusio\Impl\Provider\Routes\OpenAPI::class,
        \Fusio\Impl\Provider\Routes\Postman::class,
        \Fusio\Impl\Provider\Routes\Insomnia::class,
    ],
];
