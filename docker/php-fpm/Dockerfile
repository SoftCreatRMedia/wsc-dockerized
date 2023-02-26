ARG PHP_VERSION=8.1

FROM php:${PHP_VERSION}-fpm-alpine
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"

RUN set -eux; \
    apk add --no-cache \
        bash \
        curl \
        libxml2-dev \
        tar \
        imagemagick \
;

# Configure & Install PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN set -eux; \
    chmod +x /usr/local/bin/install-php-extensions && IPE_GD_WITHOUTAVIF=1 install-php-extensions \
        exif \
        intl \
        gd \
        gmp \
        imagick \
        pdo_mysql \
        redis \
        opcache \
;

# Setup entrypoint and start
COPY ./start-container.sh /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

ENTRYPOINT start-container /wsc $WSC_VERSION
