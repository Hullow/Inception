# Developer documentation (DEV_DOC)

## Prerequisites
- Linux VM (recommended by the subject)
- Docker Engine + Docker Compose (plugin or standalone)
- GNU Make

## Configuration files
- Compose: `srcs/docker-compose.yml`
- Environment (non-secret): `srcs/.env`
- Secrets (secret): `secrets/*` mounted into containers under `/run/secrets/*`

Required secret files (1 value per file):
- `secrets/db_root_password`
- `secrets/db_password`
- `secrets/wp_admin_password`
- `secrets/wp_user_password`

## Build and launch
All commands below run from the repository root:
- Build + start (detached): `make up` (or `make`)
- Stop: `make down`
- Rebuild: `make build`
- Rebuild and restart: `make re`

Under the hood, the Makefile runs:
- `docker compose -f srcs/docker-compose.yml --env-file srcs/.env ...`

## Services and runtime behavior
- `mariadb` (`srcs/requirements/mariadb/tools/mariadb-entrypoint.sh`)
  - Initializes the DB once (when `/var/lib/mysql/mysql` is missing), creates DB/user, then runs `mysqld` in foreground.
  - Reads passwords from `/run/secrets/db_root_password` and `/run/secrets/db_password`.
- `wordpress` (`srcs/requirements/wordpress/tools/wordpress-entrypoint.sh`)
  - Waits for MariaDB, downloads WordPress on first run, creates `wp-config.php`, installs WP, creates the second user.
  - Runs php-fpm in foreground (`CMD ["php-fpm8.2", "-F"]`).
- `nginx` (`srcs/requirements/nginx/tools/nginx-entrypoint.sh`)
  - Generates a self-signed cert if missing, templates `server_name` from `DOMAIN_NAME`, runs nginx in foreground.
  - TLS is restricted to `TLSv1.2 TLSv1.3` in `srcs/requirements/nginx/conf/nginx.conf.template`.

Note: WordPress is downloaded at runtime (`curl https://wordpress.org/latest.tar.gz`), and WP-CLI is downloaded at build time. If your environment has no network access, vendor these artifacts into the image and replace the `curl` steps with `COPY`.

## Data persistence
Named volumes are declared in `srcs/docker-compose.yml`:
- `db_data` mounted at `/var/lib/mysql` in `mariadb`
- `wp_data` mounted at `/var/www/html` in `wordpress` and read-only in `nginx`

Inspect:
- `docker volume ls`
- `docker volume inspect srcs_db_data`
- `docker volume inspect srcs_wp_data`

On the host, Docker typically stores volume data under `/var/lib/docker/volumes/` (path depends on your Docker/VM setup).

## Useful commands
- Container list: `docker ps`
- Compose status: `make ps`
- Follow logs: `make logs`
- Exec into a container: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec <service> sh`
- Tear down and remove orphan resources:
  - `docker compose -f srcs/docker-compose.yml --env-file srcs/.env down --remove-orphans`
