# https://hub.docker.com/_/nginx/
FROM nginx:1.19.3-alpine

# Copy config files to container
COPY templates /opt/templates

# Shell scripts to run on build
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["-g", "daemon off;"]
