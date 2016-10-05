# mariadb-galera
Clusterable, auto-discoverable MariaDB galera cluster - made for Docker Cloud

Built with [the useful topic from Withblue.ink](http://withblue.ink/2016/03/09/galera-cluster-mariadb-coreos-and-docker-part-1.html).

# Project description
Goal of this project is to create an easily deployable MariaDB cluster, that can scale up and down without configuration/setup assle.
It uses `HOSTNAME` (or `DOCKERCLOUD_CONTAINER_HOSTNAME` on Docker Cloud) env vars to discover other hosts (mariadb-1, mariadb-2, mariadb-3, etc.). Container named with `{name}-1` will be the galera cluster creator.

The container is ready to use with Docker Cloud.

# Build and run
## Manual (to try it locally)
```sh
docker build -t dialonce/mariadb-galera:latest .
docker run -it -e MYSQL_ROOT_PASSWORD=root --name=mariadb-1 -e HOSTNAME=mariadb-1 --rm -p 3306:3306 dialonce/mariadb-galera:latest
docker run -it -e MYSQL_ALLOW_EMPTY_PASSWORD=true --name=mariadb-2 -e HOSTNAME=mariadb-2 --rm --link mariadb-1:mariadb-1 dialonce/mariadb-galera:latest
```

## Docker Cloud YML
```yml
mariadb-production:
  environment:
    - MYSQL_ROOT_PASSWORD='password'
  image: 'dialonce/mariadb-galera:latest'
  ports:
    - '3306:3306'
  volumes:
    - '/data/mysql:/data'
```

# Env vars
| Name          | Example       | Description  |
| ------------- |:-------------:|--------------|
| HOSTNAME      | `mariadb-1`     | The container hostname. Container named `{name}-1` will be the Galera master. |
| MYSQL_ROOT_PASSWORD | `pass`    | The cluster root password. |
| MYSQL_ALLOW_EMPTY_PASSWORD | `anything` | Allow empty root password |
| MYSQL_RANDOM_ROOT_PASSWORD | `anything` | Generates a random root password |
| MYSQL_DATABASE | `anything` | A database name to create on first launch |
| MYSQL_USER | `username` | An user name to create on first launch. Must provide `MYSQL_PASSWORD` env var. If `MYSQL_DATABASE` is provided, it will be granted access to it |
| MARIADB_DEFAULT_STORAGE_ENGINE | `InnoDB` | The default storage engine to use for the node |
| GALERA_SLAVE_THREADS | `1` | Number of slave threads to start, [see doc](https://mariadb.com/kb/en/mariadb/galera-cluster-system-variables/#wsrep_slave_threads) |
