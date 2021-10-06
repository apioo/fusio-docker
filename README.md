# Fusio docker container

Official docker container of Fusio. More information about Fusio at: 
https://www.fusio-project.org

## Usage

The most simple usage is to use the provided `docker-compose.yml` file. Use the
following command to setup a mysql and fusio container.

```
docker-compose up -d
```

NOTE: You MUST change the default passwords which are defined in the 
`docker-compose.yml` file before running this container on the internet.
Also by default the hostname is `api.fusio.cloud` but you can adjust this
via the env settings.

## Worker

Besides the database we set up also different worker instances to enable
the usage of different programming languages. If you dont need support
for these programming languages you can disable them in the configuration.
Fusio will also work if these instances are not available.

## Certificate

The image contains a script to automatically obtain a SSL certificate for the
domain. By default this feature ist deactivated, to activate this you need to set
the env FUSIO_CERTBOT to 1, then after start the container will try to obtain a
certificate. Note this only works in case you container is reachable on the internet.

### Run

If you dont want to use the `docker-compose` command you can create and link 
the needed containers also manually:

#### Mysql

```
$ docker run -d --name mysql_fusio \
  -e "MYSQL_ROOT_PASSWORD=61ad6c605975" \
  -e "MYSQL_USER=fusio" \
  -e "MYSQL_PASSWORD=61ad6c605975" \
  -e "MYSQL_DATABASE=fusio" \
  mysql:5.7
```

#### Fusio

```
$ docker run -d --name fusio \
  -p 80:80 \
  --link mysql_fusio:db \
  -e "FUSIO_PROJECT_KEY=42eec18ffdbffc9fda6110dcc705d6ce" \
  -e "FUSIO_DOMAIN=api.fusio.cloud" \
  -e "FUSIO_HOST=api.fusio.cloud" \
  -e "FUSIO_URL=http://api.fusio.cloud" \
  -e "FUSIO_APPS_URL=http://api.fusio.cloud/apps" \
  -e "FUSIO_ENV=prod" \
  -e "FUSIO_DB_NAME=fusio" \
  -e "FUSIO_DB_USER=fusio" \
  -e "FUSIO_DB_PW=61ad6c605975" \
  -e "FUSIO_DB_HOST=mysql_fusio" \
  -e "FUSIO_BACKEND_USER=demo" \
  -e "FUSIO_BACKEND_EMAIL=demo@fusio-project.org" \
  -e "FUSIO_BACKEND_PW=61ad6c605975" \
  fusio/fusio
```
