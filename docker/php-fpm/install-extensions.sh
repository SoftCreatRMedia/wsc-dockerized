#!/bin/sh

set -eux

sh /usr/local/bin/check-php-version.sh "$WSC_VERSION"

apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends \
    bash \
    curl \
    libxml2-dev \
    tar \
    imagemagick
curl -sL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o /usr/local/bin/install-php-extensions
chmod +x /usr/local/bin/install-php-extensions

WSC_VERSION_NORMALIZED="$(printf '%s' "$WSC_VERSION" | grep -Eo '^[0-9]+(\.[0-9]+){1,2}' || true)"
EXTENSIONS="exif intl gd gmp imagick pdo_mysql opcache"
if [ -z "$WSC_VERSION_NORMALIZED" ] || dpkg --compare-versions "$WSC_VERSION_NORMALIZED" lt 6.3; then
    EXTENSIONS="$EXTENSIONS redis"
fi
IPE_GD_WITHOUTAVIF=1 install-php-extensions $EXTENSIONS
rm /usr/local/bin/install-php-extensions
rm -rf /var/lib/apt/lists/*
