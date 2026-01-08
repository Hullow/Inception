# User documentation (USER_DOC)

## What this stack provides
- `nginx`: HTTPS reverse proxy (only exposed port: `443`), serves WordPress files and forwards PHP requests to php-fpm.
- `wordpress`: WordPress + php-fpm (`9000`), initializes WordPress on first start.
- `mariadb`: database server for WordPress.
- Persistent data:
  - WordPress files: Docker volume `wp_data`
  - MariaDB data: Docker volume `db_data`

## Start / stop
From the repository root:
- Start (build if needed): `make up`
- Stop: `make down`
- View status: `make ps`
- Follow logs: `make logs`

## Access the website and admin panel
1. Ensure `DOMAIN_NAME` in `srcs/.env` resolves to your VM IP (edit your host `/etc/hosts` if needed).
2. Open:
   - `https://<DOMAIN_NAME>/` (website)
   - `https://<DOMAIN_NAME>/wp-admin/` (admin)
3. TLS is self-signed: accept the warning, or test with `curl -k https://<DOMAIN_NAME>`.
4. Admin login:
   - Username: `WP_ADMIN_USER` from `srcs/.env`
   - Password: `secrets/wp_admin_password`

## Credentials and where they live
Non-secret configuration is in `srcs/.env` (domain, WP/DB usernames, emails, etc.).

Passwords are stored as Docker secrets (files) in `secrets/`:
- DB: `secrets/db_root_password`, `secrets/db_password`
- WordPress: `secrets/wp_admin_password`, `secrets/wp_user_password`

To view a password locally:
- `cat secrets/wp_admin_password`

## Check everything is running correctly
- Compose status: `make ps`
- Basic HTTPS check (ignores self-signed TLS): `curl -k https://<DOMAIN_NAME>`
- Logs per service:
  - `docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f nginx`
  - `docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f wordpress`
  - `docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f mariadb`

## Common admin operations
- Restart a service: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env restart <service>`
- Open a shell in a container: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec <service> sh`
- Reset WordPress (destroys persisted data): stop the stack, remove volumes, start again:
  - `make down`
  - `docker volume rm srcs_wp_data srcs_db_data`
  - `make up`
