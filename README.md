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
