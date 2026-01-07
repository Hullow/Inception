FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx openssl gettext-base \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY tools/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

# n.b.: nginx has to stay in the foreground otherwise it's interpreted 
# as PID 1 ending and the container stops 