FROM alpine:3.4

MAINTAINER jmuller@dial-once.com

ENV LANG="en_US.UTF-8" \
  LC_ALL="en_US.UTF-8" \
  LANGUAGE="en_US.UTF-8" \
  DB_USER="root" \
  DB_PASS="root" \
  TERM="xterm" \
  DOCKERIZE_VERSION="0.2.0"

RUN apk -U upgrade --no-cache && \
    apk --update add --no-cache mariadb ca-certificates wget && \
    # Install Dockerize for dynamic conf on load
    wget -O - https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz | tar -xzf - -C /usr/local/bin && \
    apk del ca-certificates wget

ADD ./run.sh /run.sh
ADD ./conf/mysql_server.cnf /mysql_server.cnf

VOLUME ["/data"]

EXPOSE 4567 4567 4568 4444 3306

CMD mkdir -p /etc/mysql/conf.d/ && \
  dockerize -template /mysql_server.cnf:/etc/mysql/conf.d/mysql_server.cnf && \
  ./run.sh
