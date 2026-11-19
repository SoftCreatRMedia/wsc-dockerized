#!/bin/sh

set -eu

if [ "$(uname -m)" != x86_64 ]; then
    printf '%s\n' 'The patched PHP 5.5 packages require linux/amd64.' >&2
    exit 1
fi

key=/etc/pki/rpm-gpg/RPM-GPG-KEY-CloudLinux
curl -fsSL https://repo.cloudlinux.com/cloudlinux/security/RPM-GPG-KEY-CloudLinux -o "$key"
printf '%s  %s\n' e6ecc0bd3c7e6f9311aa39fd422fe0329461d85af31b6e0c7d70544185c48f36 "$key" | sha256sum -c -

cat > /etc/yum.repos.d/cloudlinux-php.repo <<'EOF'
[cloudlinux-baseos]
name=CloudLinux 9 BaseOS
baseurl=https://repo.cloudlinux.com/cloudlinux/9/BaseOS/$basearch/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CloudLinux
includepkgs=alt-*,cloudlinux-linksafe,freetds,freetds-libs,x265-libs

[cloudlinux-appstream]
name=CloudLinux 9 AppStream
baseurl=https://repo.cloudlinux.com/cloudlinux/9/AppStream/$basearch/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CloudLinux
includepkgs=alt-*,cloudlinux-linksafe,t1lib
EOF

dnf -y --setopt=install_weak_deps=False install \
    alt-php55-cli alt-php55-php-fpm alt-php55-gd alt-php55-intl alt-php55-mbstring \
    alt-php55-mysqlnd alt-php55-opcache alt-php55-pecl-imagick alt-php55-pecl-redis alt-php55-xml
dnf clean all

php_root=/opt/alt/php55
ln -s "$php_root/usr/bin/php" /usr/local/bin/php
ln -s "$php_root/usr/sbin/php-fpm" /usr/local/sbin/php-fpm
sh /usr/local/bin/check-php-version.sh "$WSC_VERSION"

mkdir -p /usr/local/etc/php/conf.d /usr/local/etc/php-fpm.d
touch /usr/local/etc/php-fpm.d/WCFSetupTemplate.conf
for extension in fileinfo json phar sockets zip gd intl mbstring pdo mysqlnd nd_mysqli nd_pdo_mysql dom xmlreader xmlwriter igbinary msgpack imagick redis; do
    printf 'extension=%s.so\n' "$extension"
done > /usr/local/etc/php/conf.d/20-extensions.ini
printf 'zend_extension=%s/usr/lib64/php/modules/opcache.so\n' "$php_root" > /usr/local/etc/php/conf.d/10-opcache.ini

useradd --system --user-group --no-create-home --shell /sbin/nologin www-data
cat > "$php_root/etc/php-fpm.conf" <<'EOF'
[global]
error_log = /proc/self/fd/2

[www]
user = www-data
group = www-data
listen = 9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
include=/usr/local/etc/php-fpm.d/*.conf
EOF
php-fpm -t
