FROM alpine:3.4

MAINTAINER jmuller@dial-once.com

ENV LANG="en_US.UTF-8" \
  LC_ALL="en_US.UTF-8" \
  LANGUAGE="en_US.UTF-8" \
  DOCKERIZE_VERSION="0.2.0" \
  MARIADB_DEFAULT_STORAGE_ENGINE="XtraDB" \
  GALERA_SLAVE_THREADS=1

RUN apk -U upgrade --no-cache && \
    apk --update add --no-cache mariadb mariadb-client ca-certificates wget bash && \
    # Install Dockerize for dynamic conf on load
    wget -O - https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz | tar -xzf - -C /usr/local/bin && \
    apk del ca-certificates wget && \
    # Prepare configuration folder for MariaDB
    mkdir -p /etc/mysql/conf.d /usr/share/zoneinfo /run/mysqld && \
    chown -R mysql:mysql /etc/mysql/conf.d /run/mysqld && \
    # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    chmod 777 /run/mysqld && \
    # Create shared volume data folder
    mkdir -p /data && chown -R mysql:mysql /data

# Startup script
ADD ./run.sh /run.sh
# Dynamic configuration script (will be compiled with env vars on boot)
ADD ./conf/mysql_server.cnf /mysql_server.cnf

VOLUME ["/data"]

# Exposed galera cluster ports + MariaDB port
EXPOSE 4567 4567 4568 4444 3306

# Run the container as 'mysql' user
USER mysql

# Create dynamic config files using env vars + launch startup script
CMD dockerize -template /mysql_server.cnf:/etc/mysql/conf.d/mysql_server.cnf && \
  ./run.sh
