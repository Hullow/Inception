FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server mariadb-client \
	&& rm -rf /var/lib/mysql/* \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld /var/lib/mysql \
	&& chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/99-inception.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf
COPY tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]