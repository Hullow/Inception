FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd php8.2-xml php8.2-mbstring php8.2-zip php8.2-cli \
	curl ca-certificates mariadb-client \
	&& rm -rf /var/lib/apt/lists/* 
	# remove cached package lists to reduce image size

# download WP-CLI (PHP tool to install/configure Wordpress)
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wordpress-entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
# CMD allows debugging

