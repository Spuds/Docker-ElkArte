#!/bin/sh

NGINX_CONF_TEMPLATE_PATH="/opt/templates/nginx.conf"
NGINX_CONF_PATH="/etc/nginx/nginx.conf"
PHP_FPM_PARAMS_TEMPLATE_PATH="/opt/templates/php_fpm_params"
PHP_FPM_PARAMS_PATH="/etc/nginx/php_fpm_params"
DEFAULT_CONF_TEMPLATE_PATH="/opt/templates/default.conf"
DEFAULT_CONF_PATH="/etc/nginx/conf.d/default.conf"

set -e

# if command starts with an option, prefix nginx
if [ "${1:0:1}" = '-' ]; then
    set -- nginx "$@"
fi

NGINX_CONF="$( cat "$NGINX_CONF_TEMPLATE_PATH" )"

if [ ! -z "$NGINX_WORKER_PROCESSES" ]; then
    NGINX_CONF="$( echo "$NGINX_CONF" | sed -e "s/^\(\s*worker_processes.*\) auto;$/\1 $NGINX_WORKER_PROCESSES;/" )"
    echo "$NGINX_CONF" | grep 'worker_processes' | xargs
fi

if [ ! -z "$NGINX_ACCESS_LOG_FORMAT" ]; then
    NGINX_CONF="$( echo "$NGINX_CONF" | sed -e "s|^\(\s*access_log.*\) off;$|\1 /var/log/nginx/access.log $NGINX_ACCESS_LOG_FORMAT;|" )"
    echo "$NGINX_CONF" | grep 'access_log' | xargs
fi

echo "$NGINX_CONF" > "$NGINX_CONF_PATH"

if [ -f "$DEFAULT_CONF_PATH" ]; then
    unlink "$DEFAULT_CONF_PATH"
fi

if [ ! -z "$NGINX_FAST_CGI_PASS" ]; then
    PHP_FPM_PARAMS="$( cat "$PHP_FPM_PARAMS_TEMPLATE_PATH" )"

    PHP_FPM_PARAMS="$( echo "$PHP_FPM_PARAMS" | sed -e "s|^\(\s*fastcgi_pass.*\) 127.0.0.1:9000;$|\1 $NGINX_FAST_CGI_PASS;|" )"
    echo "$PHP_FPM_PARAMS" | grep 'fastcgi_pass' | xargs

    echo "$PHP_FPM_PARAMS" > "$PHP_FPM_PARAMS_PATH"

    DEFAULT_CONF="$( cat "$DEFAULT_CONF_TEMPLATE_PATH" )"

    echo "$DEFAULT_CONF" > "$DEFAULT_CONF_PATH"
fi

echo "Executing $@..."
exec "$@"