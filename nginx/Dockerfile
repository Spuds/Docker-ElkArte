# https://hub.docker.com/_/nginx/
FROM nginx:1.29.0-alpine

# Copy config files to container
COPY templates /opt/templates

# Shell scripts to run on build
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# run nginx in foreground
CMD ["-g", "daemon off;"]
