#!/bin/sh

set -eu

php_version="$(php -n -r 'echo PHP_MAJOR_VERSION, ".", PHP_MINOR_VERSION, ".", PHP_RELEASE_VERSION;')"
php_series="${php_version%.*}"
wsc_version="$(printf '%s' "$1" | grep -Eo '^[0-9]+(\.[0-9]+){1,2}' || true)"
sury_minimum=
cloudlinux_minimum=

# First releases that fix CVE-2026-109618 and CVE-2026-109619.
case "$php_series" in
    5.5) cloudlinux_minimum=5.5.38-183 ;;
    5.6) sury_minimum=5.6.40-104 ;;
    7.0) sury_minimum=7.0.33-92 ;;
    7.1) sury_minimum=7.1.33-80 ;;
    7.2) sury_minimum=7.2.34-66 ;;
    7.3) sury_minimum=7.3.33-35 ;;
    7.4) sury_minimum=1:7.4.33-31 ;;
    8.0) sury_minimum=1:8.0.30-25 ;;
    8.1) sury_minimum=8.1.34-9 ;;
    8.2) minimum=8.2.35 ;;
    8.3) minimum=8.3.36 ;;
    8.4) minimum=8.4.27 ;;
    8.5) minimum=8.5.12 ;;
    *)
        printf 'PHP %s is outside the supported image series.\n' "$php_version" >&2
        exit 1
        ;;
esac

if [ -n "$cloudlinux_minimum" ]; then
    for package in alt-php55-cli alt-php55-php-fpm; do
        revision="$(rpm -q --qf '%{VERSION}-%{RELEASE}' "$package")"
        if [ "$(printf '%s\n' "$cloudlinux_minimum" "$revision" | sort -V | tail -n 1)" != "$revision" ]; then
            printf '%s %s is below the patched package revision %s.\n' "$package" "$revision" "$cloudlinux_minimum" >&2
            exit 1
        fi
    done
elif [ -n "$sury_minimum" ]; then
    for sapi in cli fpm; do
        package="php$php_series-$sapi"
        revision="$(dpkg-query -W -f='${Version}' "$package")"
        if ! dpkg --compare-versions "$revision" ge "$sury_minimum"; then
            printf '%s %s is below the patched package revision %s.\n' "$package" "$revision" "$sury_minimum" >&2
            exit 1
        fi
    done
elif ! dpkg --compare-versions "$php_version" ge "$minimum"; then
    printf 'PHP %s is below the security minimum of %s for PHP %s.\n' "$php_version" "$minimum" "$php_series" >&2
    exit 1
fi

if [ -n "$wsc_version" ] && [ "$(printf '%s\n' 6.3 "$wsc_version" | sort -V | tail -n 1)" = "$wsc_version" ]; then
    case "$php_series" in
        8.4|8.5) ;;
        *)
            printf 'WoltLab Suite %s requires PHP 8.4.27+ in the 8.4 series or PHP 8.5.12+ in the 8.5 series. Found PHP %s.\n' "$1" "$php_version" >&2
            exit 1
            ;;
    esac
fi
