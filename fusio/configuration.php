<?php

if (!getenv('FUSIO_ENV')) {
    $dotenv = new \Symfony\Component\Dotenv\Dotenv();
    $dotenv->usePutenv(true);
    $dotenv->load(__DIR__ . '/.env');
}

return [

    // This array contains a list of worker endpoints which can be used by Fusio to execute action code in different
    // programming languages. For more information please take a look at our worker documentation:
    // https://www.fusio-project.org/documentation/worker
    'fusio_worker'            => array_filter([
        'java'                => getenv('FUSIO_WORKER_JAVA'),
        'javascript'          => getenv('FUSIO_WORKER_JAVASCRIPT'),
        'php'                 => getenv('FUSIO_WORKER_PHP'),
        'python'              => getenv('FUSIO_WORKER_PYTHON'),
    ]),

    // OAuth2 access token expiration settings. How long can you use an access token and the refresh token. After the
    // expiration a user either need to use a refresh token to extend the token or request a new token
    'fusio_expire_token'      => 'P2D',
    'fusio_expire_refresh'    => 'P3D',

    // The secret key of a project. It is recommended to change this to another random value. This is used i.e. to
    // encrypt the connection credentials in the database. NOTE IF YOU CHANGE THE KEY FUSIO CAN NO LONGER READ ANY DATA
    // WHICH WAS ENCRYPTED BEFORE. BECAUSE OF THAT IT IS RECOMMENDED TO CHANGE THE KEY ONLY BEFORE THE INSTALLATION
    'fusio_project_key'       => getenv('FUSIO_PROJECT_KEY'),

    // Indicates whether the PHP sandbox feature is enabled. If yes it is possible to use the PHP-Sandbox action which
    // executes PHP code directly on the server. The code gets checked by a parser which prevents the use of unsafe
    // functions but there is no guarantee that this is complete safe. Otherwise you can also use the PHP worker which
    // executes the code at the worker.
    'fusio_php_sandbox'       => getenv('FUSIO_PHP_SANDBOX') === 'on',

    // The three-character ISO-4217 currency code which is used to process payments
    'fusio_payment_currency'  => getenv('FUSIO_PAYMENT_CURRENCY') ?: 'EUR',

    // Points to the Fusio provider file which contains specific classes for the system. Please take a look at the
    // provider file for more information
    'fusio_provider'          => __DIR__ . '/provider.php',

    // Settings of the internal mailer. More information s.
    // https://symfony.com/doc/current/mailer.html#using-built-in-transports
    'fusio_mailer'            => getenv('FUSIO_MAILER'),

    // Describes the default email which Fusio uses as from address
    'fusio_mail_sender'       => getenv('FUSIO_MAIL_SENDER'),

    // Indicates whether the marketplace is enabled. If yes it is possible to download and install other apps through
    // the backend
    'fusio_marketplace'       => getenv('FUSIO_MARKETPLACE') === 'on',

    // Endpoint of the apps repository. All listed apps can be installed by the user at the backend app
    'fusio_marketplace_url'   => 'https://www.fusio-project.org/marketplace.yaml',

    // The public url to the apps folder (i.e. http://acme.com/apps or http://apps.acme.com)
    'fusio_apps_url'          => getenv('FUSIO_APPS_URL'),

    // Location where the apps are persisted from the marketplace. By default this is the public dir to access the apps
    // directly, but it is also possible to specify a different folder
    'fusio_apps_dir'          => __DIR__ . '/public/apps',

    // The public url to the public folder (i.e. http://acme.com/public or http://acme.com)
    'psx_url'                 => getenv('FUSIO_URL'),

    // To enable clean urls you need to set this to '' this works only in case mod rewrite is activated
    'psx_dispatch'            => '',

    // The default timezone
    'psx_timezone'            => 'UTC',

    // Whether PSX runs in debug mode or not. If not error reporting is set to 0 also several caches are used if the
    // debug mode is false
    'psx_debug'               => getenv('FUSIO_ENV') != 'prod',

    // Database parameters which are used for the doctrine DBAL connection
    // http://docs.doctrine-project.org/projects/doctrine-dbal/en/latest/reference/configuration.html
    'psx_connection'          => [
        'dbname'              => getenv('FUSIO_DB_NAME'),
        'user'                => getenv('FUSIO_DB_USER'),
        'password'            => getenv('FUSIO_DB_PW'),
        'host'                => getenv('FUSIO_DB_HOST'),
        'driver'              => getenv('FUSIO_DB_DRIVER') ?: 'pdo_mysql',
        'driverOptions'       => [
            // dont emulate so that we can use prepared statements in limit clause
            \PDO::ATTR_EMULATE_PREPARES => false
        ],
    ],

    // Folder locations
    'psx_path_cache'          => '/tmp',
    'psx_path_public'         => __DIR__ . '/public',
    'psx_path_src'            => __DIR__ . '/src',

    // Supported writers
    'psx_supported_writer'    => [
        \PSX\Data\Writer\Json::class,
        \PSX\Data\Writer\Jsonp::class,
        \PSX\Data\Writer\Jsonx::class,
    ],

    // Global middleware which are applied before and after every request. Must bei either a classname, closure or
    // PSX\Http\FilterInterface instance
    //'psx_filter_pre'          => [],
    //'psx_filter_post'         => [],

    // A closure which returns a symfony cache implementation. If null the filesystem cache is used. Please take a look
    // at the repository to see all available adapter: https://github.com/symfony/cache
    /*
    'psx_cache_factory'         => function($config, $namespace){
        $client = new \Memcached();
        $client->addServer(getenv('FUSIO_MEMCACHE_HOST'), getenv('FUSIO_MEMCACHE_PORT'));

        return new \Symfony\Component\Cache\Adapter\MemcachedAdapter($client, $namespace);
    },
    */

    // Specify a specific log level
    //'psx_log_level' => \Monolog\Logger::ERROR,

    // A closure which returns a monolog handler implementation. If null the system handler is used
    //'psx_logger_factory'      => null,

];
