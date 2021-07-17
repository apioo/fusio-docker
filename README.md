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

### Run

If you dont want/can use the `docker-compose` command you can create and link 
the needed containers also manually. Therefor you need to create the following 
containers:

#### Mysql

```
$ docker run -d --name fusio-db \
  -e "MYSQL_ROOT_PASSWORD=7f3e5186032a" \
  -e "MYSQL_USER=fusio" \
  -e "MYSQL_PASSWORD=61ad6c605975" \
  -e "MYSQL_DATABASE=fusio" \
  mysql:5.7
```

#### Fusio

```
$ docker run -d --name fusio \
  -p 80:80 \
  --link fusio-db:db \
  -e "FUSIO_PROJECT_KEY=42eec18ffdbffc9fda6110dcc705d6ce" \
  -e "FUSIO_HOST=api.fusio.cloud" \
  -e "FUSIO_URL=https://api.fusio.cloud" \
  -e "FUSIO_ENV=dev" \
  -e "FUSIO_DB_USER=fusio" \
  -e "FUSIO_DB_PW=61ad6c605975" \
  -e "FUSIO_DB_HOST=db" \
  -e "FUSIO_DB_NAME=fusio" \
  -e "FUSIO_BACKEND_USER=demo" \
  -e "FUSIO_BACKEND_EMAIL=demo@fusio-project.org" \
  -e "FUSIO_BACKEND_PW=c6/337d2ef_c" \
  fusio/fusio:latest
```
