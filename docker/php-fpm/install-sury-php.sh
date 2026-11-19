#!/bin/sh

set -eu

series="$1"
package="php$series"
export DEBIAN_FRONTEND=noninteractive

apt-get update -o APT::Update::Error-Mode=any
apt-get install -y --no-install-recommends ca-certificates curl imagemagick

keyring=/tmp/debsuryorg-archive-keyring.deb
curl -fsSL https://packages.sury.org/debsuryorg-archive-keyring.deb -o "$keyring"
printf '%s  %s\n' 7511384559c9ddf1d5ce5f60be429ae9d4e7d01d9480d6f1b7a30c0810cf8b60 "$keyring" | sha256sum -c -
dpkg -i "$keyring"
rm "$keyring"
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ trixie main' > /etc/apt/sources.list.d/sury-php.list
apt-get update -o APT::Update::Error-Mode=any
apt-get install -y --no-install-recommends \
    "$package-cli" "$package-fpm" "$package-curl" "$package-gd" "$package-gmp" \
    "$package-imagick" "$package-intl" "$package-mbstring" "$package-mysql" \
    "$package-opcache" "$package-redis" "$package-xml" "$package-zip"
sh /usr/local/bin/check-php-version.sh "$WSC_VERSION"

conf="/etc/php/$series"
mkdir -p /run/php /usr/local/etc/php/conf.d /usr/local/etc/php-fpm.d
touch /usr/local/etc/php/conf.d/php-overrides.ini /usr/local/etc/php-fpm.d/WCFSetupTemplate.conf
ln -s "/usr/sbin/php-fpm$series" /usr/local/sbin/php-fpm
ln -s /usr/local/etc/php/conf.d/php-overrides.ini "$conf/cli/conf.d/99-wsc.ini"
ln -s /usr/local/etc/php/conf.d/php-overrides.ini "$conf/fpm/conf.d/99-wsc.ini"
ln -s /usr/local/etc/php-fpm.d/WCFSetupTemplate.conf "$conf/fpm/pool.d/zz-wsc-setup.conf"
printf '%s\n' '[www]' 'listen = 9000' > "$conf/fpm/pool.d/zz-wsc-listen.conf"
sed -i 's|^error_log = .*|error_log = /proc/self/fd/2|' "$conf/fpm/php-fpm.conf"
php-fpm -t

rm -rf /var/lib/apt/lists/*
