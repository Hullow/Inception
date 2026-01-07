#!/bin/sh

set -eu
# -e: stop on error (a command exits with a non-zero status)
# -u: error on unset variables

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
ROOT_PW_FILE="/run/secrets/db_root_password"
USER_PW_FILE="/run/secrets/db_password"

if [ ! -f "$ROOT_PW_FILE" ] || [ ! -f "$USER_PW_FILE" ]; then
	echo "Missing DB secrets" >&2
	exit 1
fi

MYSQL_ROOT_PASSWORD="$(cat "$ROOT_PW_FILE")"
MYSQL_PASSWORD="$(cat "$USER_PW_FILE")"

if [ ! -d "$DATADIR/mysql" ]; then
	mariadb-install-db --user=mysql --datadir="$DATADIR"

	# temporary server instance (in the background) to initialise the database and users
	mysqld --user=mysql --datadir="$DATADIR" --skip-networking --socket="$SOCKET" &
	pid="$!"

	# ping the server
	for i in $(seq 1 30); do
		if mysqladmin --socket="$SOCKET" ping >/dev/null 2>&1; then
			break
		fi
		sleep 1
	done

	if ! mysqladmin --socket="$SOCKET" ping >/dev/null 2>&1; then
		echo "MariaDB init failed" >&2
		exit 1
	fi

	mysql --socket="$SOCKET" <<-SQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
SQL

	mysqladmin --socket="$SOCKET" shutdown
	wait "$pid"
fi

exec mysqld --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0