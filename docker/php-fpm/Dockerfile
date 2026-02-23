ARG PHP_VERSION=8.4
ARG WSC_VERSION=6.2

FROM php:${PHP_VERSION}-fpm
ARG WSC_VERSION
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
    WSC_VERSION_NORMALIZED="$(printf '%s' "$WSC_VERSION" | grep -Eo '^[0-9]+(\.[0-9]+){1,2}' || true)"; \
    EXTENSIONS="exif intl gd gmp imagick pdo_mysql opcache"; \
    if [ -n "$WSC_VERSION_NORMALIZED" ]; then \
        if dpkg --compare-versions "$WSC_VERSION_NORMALIZED" lt "6.3"; then \
            EXTENSIONS="$EXTENSIONS redis"; \
        fi; \
    else \
        EXTENSIONS="$EXTENSIONS redis"; \
    fi; \
    IPE_GD_WITHOUTAVIF=1 install-php-extensions $EXTENSIONS; \
    rm /usr/local/bin/install-php-extensions; \
    rm -rf /var/lib/apt/lists/*

# Setup entrypoint
COPY ./start-container.sh /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

ENTRYPOINT bash start-container /wsc $WSC_VERSION
