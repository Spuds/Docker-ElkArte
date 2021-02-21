FROM php:8.0.2-fpm-alpine

# Use id -u on host for the user you wish to use.  The container will then add a www-user with this same value
# and run under that id so host<->container permissions match
ARG USER_ID=999
ARG GROUP_ID=1001

RUN set -x && \
    apk update && \
    apk upgrade

# Install core dependencies
RUN apk add --update --no-cache \
    libzip \
    git \
    patch \
    bash \
    unzip \
    postgresql-libs \
    libmemcached-libs \
    zlib \
    aspell-en \
    imap-dev \
    aspell-dev \
    libpng-dev

ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev

# Install build dependencies
RUN apk add --update --no-cache --virtual .docker-php-global-dependencies \
    # Build dependencies for gd \
    freetype-dev \
    libjpeg-turbo-dev \
    # Build dependency for mbstring \
    oniguruma-dev \
    # Build dependencies for XML part \
    libxml2-dev \
    ldb-dev \
    # Build dependencies for Zip \
    libzip-dev \
    # Build dependencies for Pecl \
    autoconf \
    g++ \
    make \
    # Build dependency for APCu \
    pcre-dev \
    # Build dependency for Curl
    curl-dev \
    # Misc build dependency \
    wget \
    # Build dependency for Postgre \
    postgresql-dev \
    # Build dependency for memcached
    libmemcached-dev \
    zlib-dev \
    cyrus-sasl-dev \
    # Build deps for imap \
    krb5-dev

# Enable compile and security optimizations
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

# Install php extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-configure zip && \
    docker-php-ext-install gd \
        opcache \
        zip \
        exif \
        pgsql \
        pdo_pgsql \
        pspell 

# Install imap
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

# Install APCu from pickle
RUN pecl install apcu && \
    docker-php-ext-enable apcu;

# Install imagick (not yet for php8)
#RUN apk add --update --no-cache \
#    imagemagick \
#    imagemagick-libs && \
#    apk add --update --no-cache --virtual .docker-php-imagick-dependencies \
#    imagemagick-dev && \
#    pecl install imagick && \
#    docker-php-ext-enable imagick

# Install MySQL
RUN apk add --update --no-cache --virtual .docker-php-mysql-dependencies \
    mysql-client && \
    docker-php-ext-configure mysqli && \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-install mysqli \
    pdo_mysql

# Install Xdebug
RUN git clone https://github.com/xdebug/xdebug.git && \
    cd xdebug && \
    ./rebuild.sh && \
    docker-php-ext-enable xdebug && \
    echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini && \
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
    fi;

ENV COMPOSER_ALLOW_SUPERUSER 1

# Server Configuration
RUN sed -i "s/^;security.limit_extensions =.*/security.limit_extensions = .php .php7 .php74/g" /usr/local/etc/php-fpm.d/www.conf
COPY php.d /usr/local/etc/php/conf.d
# COPY php.ini-development /usr/local/etc/php/php.ini
COPY etc /usr/local/etc/php

# Give access to the volume data, set www-data in container to match host 
RUN apk add shadow && \ 
    usermod -u ${USER_ID} www-data || true && \
    groupmod -g ${GROUP_ID} www-data || true && \
    chown -R ${USER_ID}:${GROUP_ID} /var/www

# Remove the dependencies we downloaded to build / compile this beauty
#apk del .docker-php-imagick-dependencies && \
RUN pecl clear-cache && \ 
    apk del .docker-php-global-dependencies && \
    apk del .docker-php-mysql-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    docker-php-source delete && \
    php -m

# Run under this id
USER ${USER_ID}
