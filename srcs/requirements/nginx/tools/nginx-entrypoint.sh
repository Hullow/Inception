#!/bin/sh

set -eu
# -e: exit on error
# -u: non-existent variables are an error

CERT_DIR="/etc/ssl/inception"
mkdir -p "$CERT_DIR"

if [ ! -f "$CERT_DIR/cert.pem" ] || [ ! -f "$CERT_DIR/key.pem" ]; then
	openssl req -x509 -nodes -newkey rsa:4096 -days 365 \
		-subj "/CN=${DOMAIN_NAME}" \
		-keyout "$CERT_DIR/key.pem" \
		-out "$CERT_DIR/cert.pem"
fi

envsubst '$DOMAIN_NAME' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"