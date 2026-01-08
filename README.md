*This project has been created as part of the 42 curriculum by fallan.*

# Inception

## Description
This project builds a small Docker infrastructure (inside a Linux VM) composed of:
- **NGINX** as the only public entrypoint on **HTTPS (443)** with **TLS 1.2/1.3** (self‑signed cert).
- **WordPress** running with **php-fpm** (no nginx inside the container).
- **MariaDB** as the database backend.
- **Docker volumes** for persistent WordPress files and database data.
- A dedicated **Docker bridge network** for service-to-service communication.

All service images are built from `debian:bookworm`, and `pull_policy: never` is used to avoid pulling pre-built service images.

## Repository layout
- `Makefile`: convenience targets wrapping Docker Compose.
- `srcs/docker-compose.yml`: services, networks, volumes, secrets.
- `srcs/.env`: non-secret configuration (domain, WP and DB usernames, etc.).
- `secrets/`: Docker secret files (gitignored).
- `srcs/requirements/*`: one Dockerfile + configs + entrypoint script per service.

## Design choices (brief)
- **VM vs Docker**: a VM virtualizes an entire OS; Docker containers isolate processes with a special filesystem while sharing the host kernel (lighter, faster).
- **Secrets vs env vars**: env vars are convenient but not suited for sensitive values; Docker **secrets** mount credentials as files under `/run/secrets/*`.
- **Docker network vs host network**: containers communicate over an isolated bridge network (`inception`) without using `network: host` (forbidden).
- **Volumes vs bind mounts**: volumes are Docker-managed persistent storage; bind mounts map a host path directly into the container (useful for dev, less isolated), that is bidirectionally modifiable.

## Instructions

### Prerequisites
- Linux VM with Docker + Docker Compose
- GNU Make

### Configuration
1. Edit `srcs/.env` and set at least `DOMAIN_NAME=<login>.42.fr`.
2. Create/update secret files in `secrets/` (each file contains the password on one line):
   - `secrets/db_root_password`
   - `secrets/db_password`
   - `secrets/wp_admin_password`
   - `secrets/wp_user_password`
3. Point your domain to the VM IP (on your host machine), for example:
   - `sudo sh -c 'echo "<VM_IP> fallan.42.fr" >> /etc/hosts'`

### Run
- Start: `make up`
- Stop: `make down`
- Logs: `make logs`
- Status: `make ps`

### Access
- Website: `https://<DOMAIN_NAME>/`
- Admin: `https://<DOMAIN_NAME>/wp-admin/`
- Self-signed TLS: use `curl -k https://<DOMAIN_NAME>` or accept the browser warning.

## Resources
- Docker docs:
  - Containers: https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/
  - Images: https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-an-image/
  - Compose: https://docs.docker.com/compose/
  - Secrets: https://docs.docker.com/compose/how-tos/use-secrets/
  - `ENTRYPOINT`/PID 1: https://docs.docker.com/reference/dockerfile/#entrypoint
  - One service per container: https://docs.docker.com/engine/containers/multi-service_container/
- AI usage: used for clarifying Docker concepts/best practices (PID 1, secrets, service separation) and cross-checking configuration decisions; implementation and final project structure are authored in this repository.