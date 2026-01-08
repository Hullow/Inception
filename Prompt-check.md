You are auditing my 42 Inception project. Be extremely thorough and strict. Verify every requirement from the subject, and point out any risk, ambiguity, or missing item. Use the repository files as the source of truth.

Deliverables:
1) A checklist of all mandatory requirements with pass/fail and evidence (file paths and key snippets).
2) Any violations or weak spots, ordered by severity.
3) Any missing documentation requirements.
4) A short list of recommended fixes.

Scope to verify (must check all):
- Runs on a VM; all project config in `srcs/`; Makefile at repo root builds and brings up everything with docker-compose.
- One service per container; compose uses a dedicated network; no `network: host` or `links` / `--link`.
- Base images are Alpine/Debian (penultimate stable); no `latest` tag.
- Images built from Dockerfiles (no prebuilt images pulled, except base OS).
- Services: NGINX with TLSv1.2/1.3 only; WordPress + php-fpm (no nginx inside); MariaDB (no nginx).
- NGINX is only entrypoint and only port 443 exposed.
- Volumes: one for DB, one for WordPress files; host path `/home/<login>/data/...`.
- Containers restart on crash; no infinite loops or hacky keep‑alive (`tail -f`, `sleep infinity`, etc). PID1 best practices.
- DB has two WP users; admin username must NOT contain admin/Admin/administrator.
- Domain configured as `<login>.42.fr`.
- No passwords in Dockerfiles; uses env vars; `.env` exists; secrets stored outside Git; recommend Docker secrets.
- README requirements: first line italicized with prescribed text; Description/Instructions/Resources with AI usage note; comparison sections (VM vs Docker, Secrets vs Env Vars, Docker Network vs Host Network, Volumes vs Bind Mounts); English only.
- Required root docs: `USER_DOC.md` and `DEV_DOC.md` with all specified content.

Also scan for:
- Any hard‑coded credentials or tokens in repo.
- Compose uses correct service names matching image names.
- NGINX TLS config correct and certs present.
- WordPress connects to DB via env vars / secrets correctly.
- `.env` is not committed (or is safe), secrets are git‑ignored.

Important: cite files precisely (e.g., `srcs/docker-compose.yml`, `srcs/requirements/nginx/Dockerfile`, `README.md`, `USER_DOC.md`, `DEV_DOC.md`, `.env`, `secrets/*`).
