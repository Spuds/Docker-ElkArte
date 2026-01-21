# Use id -u on host for the user you wish to use.
# The container will then add a www-user with this same value
# and run under that id so host<->container permissions match
ARG USER_ID=999
ARG GROUP_ID=1001

RUN set -x && \
    apk update && \
    apk upgrade

# --------------------------------------------------------------------
# Runtime dependencies (these MUST stay for extensions to run)
# --------------------------------------------------------------------
RUN apk add --no-cache \
    libzip \
    git \
    patch \
    bash \
    unzip \
    postgresql-libs \
    libmemcached-libs \
    zlib \
    aspell-en \
    aspell-dev \
    libpng \
    libwebp \
    freetype \
    libjpeg-turbo \
    imagemagick \
    imagemagick-libs \
    mysql-client \
    shadow \
    krb5 \
    libxml2 \
    imap-dev \
    curl

ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev

# --------------------------------------------------------------------
# Build dependencies (will be removed after build)
# --------------------------------------------------------------------
RUN apk add --no-cache --virtual .docker-php-build-deps \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    oniguruma-dev \
    libxml2-dev \
    samba-dev \
    libzip-dev \
    autoconf \
    g++ \
    make \
    pcre-dev \
    curl-dev \
    wget \
    postgresql-dev \
    libmemcached-dev \
    zlib-dev \
    cyrus-sasl-dev \
    krb5-dev \
    imagemagick-dev

# Enable compile and security optimizations
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

# --------------------------------------------------------------------
# PHP extensions
# --------------------------------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-configure zip && \
    docker-php-ext-install -j$(nproc) \
        gd \
        opcache \
        zip \
        exif \
        pgsql \
        pdo_pgsql \
        pspell

# Install imap
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

# Install APCu from pecl
RUN pecl install apcu && \
    docker-php-ext-enable apcu

# Install imagick
RUN pecl install imagick && \
    docker-php-ext-enable imagick

# Install MySQL extensions
RUN docker-php-ext-configure mysqli && \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-install mysqli pdo_mysql

# Install Xdebug
RUN apk add --no-cache linux-headers && \
    git clone https://github.com/xdebug/xdebug.git && \
    cd xdebug && \
    ./rebuild.sh && \
    docker-php-ext-enable xdebug && \
    echo "#xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.host" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    cd .. && \
    rm -rf xdebug

# Install memcached
RUN pecl install memcached && \
    echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini && \
    rm -rf /usr/share/php7

# Install Composer
RUN EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');") && \
    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then \
        >&2 echo 'ERROR: Invalid installer signature' && \
        rm composer-setup.php && \
        exit 1; \
    else \
        php composer-setup.php --install-dir=/usr/bin --filename=composer && \
        RESULT=$? && \
        rm composer-setup.php && \
        exit $RESULT && \
        composer -V; \
    fi

ENV COMPOSER_ALLOW_SUPERUSER 1

# --------------------------------------------------------------------
# PHP configs
# --------------------------------------------------------------------
RUN sed -i "s/^;security.limit_extensions =.*/security.limit_extensions = .php .php7 .php74 .php8/g" /usr/local/etc/php-fpm.d/www.conf
COPY php.d/01-security.ini /usr/local/etc/php/conf.d
COPY php.d/02-memory.ini /usr/local/etc/php/conf.d
COPY php.d/03-development.ini /usr/local/etc/php/conf.d
RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
COPY etc/opcache-recommended.ini /usr/local/etc/php
COPY etc/php-cli.ini /usr/local/etc/php

# --------------------------------------------------------------------
# User & permissions
# --------------------------------------------------------------------
RUN usermod -u ${USER_ID} www-data || true && \
    groupmod -g ${GROUP_ID} www-data || true && \
    chown -R ${USER_ID}:${GROUP_ID} /var/www

# --------------------------------------------------------------------
# Cleanup build dependencies
# --------------------------------------------------------------------
RUN pecl clear-cache && \
    apk del .docker-php-build-deps && \
    rm -rf /var/cache/apk/* /tmp/* && \
    docker-php-source delete && \
    php -m

# Run under this id
USER ${USER_ID}
