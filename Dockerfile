FROM mariadb:10.1

MAINTAINER jmuller@dial-once.com

ENV DOCKERIZE_VERSION="0.2.0" \
  GALERA_SLAVE_THREADS=1 \
  MARIADB_DEFAULT_STORAGE_ENGINE=InnoDB

RUN apt-get update && apt-get install wget -y && \
  wget -O - https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz | tar -xzf - -C /usr/local/bin && \
  apt-get remove wget --purge -y && apt-get autoremove --purge -y &&\
  # Prepare configuration folder for MariaDB
  mkdir -p /etc/mysql/conf.d /usr/share/zoneinfo /run/mysqld /data && \
  chown -R mysql:mysql /etc/mysql/conf.d /run/mysqld /var/lib/mysql /data && \
  # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
  chmod 777 /run/mysqld

# Dynamic configuration script (will be compiled with env vars on boot)
ADD ./conf/mysql_server.cnf /mysql_server.cnf
ADD ./run.sh /run.sh

# Exposed galera cluster ports + MariaDB port
EXPOSE 4567 4568 4444 3306

VOLUME ["/data"]

USER mysql

CMD dockerize -template /mysql_server.cnf:/etc/mysql/conf.d/mysql_server.cnf && /run.sh
