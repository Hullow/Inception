#!/bin/sh

set -eu
# -e: stop on error (a command exits with a non-zero status)
# -u: error on unset variables

DB_HOST="mariadb"
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASS="$(cat /run/secrets/db_password)"

WP_PATH="/var/www/html"

# try to reach mariaDB for ~30 seconds
for i in $(seq 1 30); do
	if mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" >/dev/null 2>&1; then
		break
	fi
	sleep 1
done

if ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" > /dev/null 2>&1; then
	echo "MariaDB not reachable" >&2
	exit 1
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
	curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wp.tar.gz
	tar -xzf /tmp/wp.tar.gz -C /tmp
	cp -r /tmp/wordpress/* "$WP_PATH"
	rm -rf /tmp/wp.tar.gz /tmp/wordpress

	# generate the wp-config.php with database settings
	wp config create --allow-root \
		--path="$WP_PATH" \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASS" \
		--dbhost="$DB_HOST" \
		--skip-check

	# install Wordpress
	wp core install --allow-root \
		--path="$WP_PATH" \
		--url="https://${DOMAIN_NAME}" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$(cat /run/secrets/wp_admin_password)" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email

	# create the second user
	wp user create --allow-root \
		--path="$WP_PATH" \
		"$WP_USER" "$WP_USER_EMAIL" \
		--user_pass="$(cat /run/secrets/wp_user_password)"
fi

# ensure Wordpress files are owned by the web server user
chown -R www-data:www-data "$WP_PATH"

exec "$@"