# Fusio docker container

Official docker container of Fusio. More information about Fusio at: 
https://www.fusio-project.org

## Usage

To get started simply run the `docker-compose.yml` file which contains MySQL and Fusio.

```
docker-compose up -d
```

NOTE: You MUST change the default passwords which are defined in the `docker-compose.yml` file before running this
container on the internet.

## MSSQL/Oracle

In case you want to use Fusio to connect to a MSSQL or Oracle database you can use the `latest-mssql` or `latest-oracle`
tag of our image which contains a configured mssql or oracle PHP extension.
