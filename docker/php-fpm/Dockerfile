ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"

# Install required packages and PHP extensions
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        libxml2-dev \
        tar \
        imagemagick; \
    curl -sL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o /usr/local/bin/install-php-extensions; \
    chmod +x /usr/local/bin/install-php-extensions; \
    IPE_GD_WITHOUTAVIF=1 install-php-extensions \
        exif \
        intl \
        gd \
        gmp \
        imagick \
        pdo_mysql \
        redis \
        opcache; \
    rm /usr/local/bin/install-php-extensions; \
    rm -rf /var/lib/apt/lists/*

# Setup entrypoint
COPY ./start-container.sh /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

ENTRYPOINT bash start-container /wsc $WSC_VERSION
