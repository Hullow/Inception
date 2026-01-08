# Notes Inception pêle-mêle

## Questions to prepare
- What is stored where ?
Volumes are stored in `/var/lib/docker/volumes/`
- Port infrastructure (where are they set and handled)

## VM setup
- Guest additions: yes (for shared folders)
- Proceed with unattended installation

### MacOS
#### Settings
- User name: vboxuser
- password: nopw
- host name: Inception
- domain name: myguest.virtualbox.org

#### Set up
- su -
- apt-get update
(normally installed: - apt-get install -y openssh-server)
- share folders: auto-mount
- Setup bridge networking to browse the website (using Adapter 1):  Virtualbox Settings>Bridged Networking>NAT>Port Forwarding>Host port 2222>Host IP 127.0.0.1>Guest port 22>Guest IP><VM_IP>
- get VM IP: `ip a`
- Setup port forwarding to SSH (using Adapter 2):  Virtualbox Settings>Networking>NAT>Port Forwarding>Host port 2222>Host IP 127.0.0.1>Guest port 22>Guest IP><VM_IP>
- in the host, map fallan.42.fr to the VM's IP: `echo "<vm-ip>fallan.42.fr" | sudo tee -a /etc/hosts`
- ssh into the machine: `ssh -p 2222 vboxuser@127.0.0.1`
- install docker: `apt-get install -y docker.io`
- install docker compose - follow this: https://docs.docker.com/engine/install/debian/#install-using-the-repository


## General
> How to understand what’s going on (quick walkthrough):

> Each image starts from debian:bookworm (penultimate stable). You’re not using prebuilt service images, which satisfies the “build your own images” requirement.<br>
> MariaDB entrypoint checks if the data dir is empty, initializes DB once, then starts mysqld in foreground. It reads secrets from /run/secrets/... so no passwords live in the Dockerfile or .env.<br>
> WordPress entrypoint waits for DB to accept connections, downloads WordPress if not present, writes wp-config.php, runs the WP install, and creates the second user. Then it runs php-fpm in the foreground.<br>
> NGINX entrypoint creates a self‑signed cert if missing, substitutes your domain into the config template, and runs NGINX in foreground with TLSv1.2/1.3 only.

## [Volumes](https://docs.docker.com/engine/storage/)
### Volume mounts
Volumes are persistent storage mechanisms managed by the Docker daemon. They retain data even after the containers using them are removed. Volume data is stored on the filesystem on the host, but in order to interact with the data in the volume, you must mount the volume to a container. Directly accessing or interacting with the volume data is unsupported, undefined behavior, and may result in the volume or its data breaking in unexpected ways.

Volumes are ideal for performance-critical data processing and long-term storage needs. Since the storage location is managed on the daemon host, volumes provide the same raw file performance as accessing the host filesystem directly.

### Bind mounts
Bind mounts create a direct link between a host system path and a container, allowing access to files or directories stored anywhere on the host. Since they aren't isolated by Docker, both non-Docker processes on the host and container processes can modify the mounted files simultaneously.

Use bind mounts when you need to be able to access files from both the container and the host.

## Secrets
> In Compose, when you attach a secret to a service:
```yaml
services:
  wordpress:
    secrets:
      - db_password
```
Docker mounts it as a file inside the container at: `/run/secrets/db_password`

## MariaDB
### [Unix sockets](https://www.baeldung.com/linux/unix-vs-tcp-ip-sockets)
`mysqld.sock`:
> Unix sockets, also known as Inter-process Communication (IPC) sockets, are data communication endpoints that allow bidirectional data exchange between processes running on the same computer.
> These sockets exchange data between processes directly in the operating system’s kernel through files on the filesystem. Processes read and write to their shared socket files to send and receive data.
> Lastly, Unix sockets are widely used by database systems that don’t need to be connected to a network interface. For instance, on Ubuntu, MySQL defaults to using /var/run/mysqld/mysql.sock for communication with local clients.

### [99-Inception.cnf]
For MariaDB/mysql: process runs the database and has `bind-address=0.0.0.0` because it needs to accept connections from all available IPV4 interfaces. This allows the database to be reached by the Wordpress (which it will do via the container interface)


## Wordpress
### Why -F (foreground)
- Because Docker considers the container to be running as PID 1 is running. If php-fpm daemonizes (backgrounds itself), PID 1 exits => the container stops.

### PHP packages
WordPress core + common plugins rely on specific PHP extensions. These are the typical minimum for a modern WP install:

php8.2-fpm: PHP FastCGI Process Manager (the server that executes PHP for NGINX).
php8.2-mysql: MySQL/MariaDB connector so WordPress can talk to the DB.
php8.2-curl: HTTP client used by WordPress for updates, plugin/theme downloads, and external requests.
php8.2-gd: Image processing (thumbnails, resizing).
php8.2-xml: XML parsing (feeds, sitemaps, plugin data).
php8.2-mbstring: Multibyte string handling (UTF‑8 text).
php8.2-zip: ZIP handling (plugin/theme install, exports).
php8.2-cli: PHP command‑line interpreter (needed for WP‑CLI).
This set is based on WordPress requirements + common plugin expectations; it’s the conservative, “it just works” base.

### www.conf
- PHP-FPM's pool config directory expects a file like www.conf by convention. www is the default pool name.
- a PHP pool is a group of PHP worker processes that share configuration (user/group, socket/port, process limits). It lets one PHP-FPM instance serve multiple apps with different settings.

### PHP and WP
- WP-CLI is a PHP script (`wp-cli.phar`)
- php8.2-cli provides the interpreter to run the wp-cli script



## potential issues
### Wordpress download via curl (wordpress-entrypoint.sh)
> Internet access: the entrypoint downloads WordPress via curl. That’s expected, but if the evaluation VM has no internet, you’d need to vendor WordPress into the image. (Most Inception setups assume internet is allowed.)

You have two practical options:
Option 1 — Vendor the files in your repo (no network at runtime or build)

Download wordpress-<version>.tar.gz and wp-cli.phar once on a machine with internet.
Place them in your project, e.g.:
wordpress.tar.gz
wp-cli.phar
Update the WordPress Dockerfile:
Replace the curl lines with COPY:
COPY tools/wp-cli.phar /usr/local/bin/wp
wordpress.tar.gz
Make wp executable.
Update the entrypoint:
Replace the curl download with tar -xzf /tmp/wordpress.tar.gz ...
This makes builds and runtime independent of internet, but your repo becomes larger.

### Docker network issues fix
```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env down --remove-orphans
docker network rm srcs_inception 2>/dev/null || true
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build
```

### VM-host networking
```bash
ip link set enp0s9 up
dhclient -v enp0s9
ip a | grep -A2 enp0s9
```

## Nginx
### Dockerfile
#### Packages
- nginx: required web server.
- openssl: needed to generate the TLS certificate in the entrypoint.
- gettext-base: provides envsubst to substitute ${DOMAIN_NAME} in the config template.
- ca-certificates: not strictly required for NGINX itself here; you can omit it for a more minimal build unless you want it for general TLS tooling.

### Config
#### TLS
> You don’t have to choose just one. The requirement means only TLS 1.2 and/or TLS 1.3 are allowed (no TLS 1.0/1.1). Using both is compliant and more compatible:

#### Location ~ \.php$
In NGINX, location can match requests in different ways. This form uses a regular expression:

> location ~ \.php$ { ... }
location starts a request‑matching block.
~ means: “the pattern that follows is a case‑sensitive regex (regular expression).”
(If it were ~*, it would be case‑insensitive.)
\.php$ is the regex pattern:
. in regex means “any character”, so to match a literal dot you escape it: \..
php matches those letters.
$ means “end of the string.”
So the whole pattern matches URIs that end with .php, like index.php, wp-login.php, etc.
Why it exists: WordPress’s front controller is index.php, and any direct PHP file requests need to be sent to PHP‑FPM instead of being served as static files.


## Tests
- in host, website up: curl -k https://fallan.42.fr
- in browser: https://fallan.42.fr
- show that volume is not bind mount: `docker volume inspect <volume_name>``
=> mountpoint: `/var/lib/docker/volumes/`
`docker exec -it <container_id> ls -la <container_volume_path>`
- to change wordpress user name, remove volume
```bash
make down
docker volume ls
docker volume rm srcs_<volume name>
docker volume rm srcs_<volume name>
make up
```

## Credentials
### MYSQL
MYSQL_USER=FALLAN
MYSQL_DATABASE=magnificent_db

### WORDPRESS
WP_TITLE=Inception
WP_ADMIN_USER=fallan
WP_ADMIN_EMAIL=fallan@42.fr
WP_USER=fallan_user
WP_USER_EMAIL=fallan.user@42.fr
DOMAIN_NAME=fallan.42.fr

# Passwords
db_password: very_secret_password

db_root_password: extremely_secret_password

wp_admin_password: secret_password

wp_user_password: not_so_secret_password