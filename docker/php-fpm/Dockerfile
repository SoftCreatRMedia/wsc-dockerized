ARG WSC_VERSION=6.2

# Select a pinned PHP image with --target. Keep 8.4 as the default (last stage).
FROM almalinux:9@sha256:02df05719ef287ebd0df0a1eedb9172a00bd70703aed7b25660e426b8e0d6047 AS php-5.5.38
ARG WSC_VERSION
ENV WSC_VERSION=$WSC_VERSION PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"
COPY check-php-version.sh install-cloudlinux-php.sh start-container.sh /usr/local/bin/
RUN sh /usr/local/bin/install-cloudlinux-php.sh
EXPOSE 9000
ENTRYPOINT ["sh", "-c", "exec bash /usr/local/bin/start-container.sh /wsc \"$WSC_VERSION\""]

FROM php-5.5.38 AS php-5.5

FROM debian:trixie-slim@sha256:a72b4433de1cf7d6bae0c4cee74d0547f58601a643b3375f070c51600d63b6b2 AS sury-php
ARG WSC_VERSION
ENV WSC_VERSION=$WSC_VERSION
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"
COPY check-php-version.sh install-sury-php.sh start-container.sh /usr/local/bin/
EXPOSE 9000
ENTRYPOINT ["sh", "-c", "exec bash /usr/local/bin/start-container.sh /wsc \"$WSC_VERSION\""]

FROM sury-php AS php-5.6.40
RUN sh /usr/local/bin/install-sury-php.sh 5.6
FROM php-5.6.40 AS php-5.6

FROM sury-php AS php-7.0.33
RUN sh /usr/local/bin/install-sury-php.sh 7.0
FROM php-7.0.33 AS php-7.0

FROM sury-php AS php-7.1.33
RUN sh /usr/local/bin/install-sury-php.sh 7.1
FROM php-7.1.33 AS php-7.1

FROM sury-php AS php-7.2.34
RUN sh /usr/local/bin/install-sury-php.sh 7.2
FROM php-7.2.34 AS php-7.2

FROM sury-php AS php-7.3.33
RUN sh /usr/local/bin/install-sury-php.sh 7.3
FROM php-7.3.33 AS php-7.3

FROM sury-php AS php-7.4.33
RUN sh /usr/local/bin/install-sury-php.sh 7.4
FROM php-7.4.33 AS php-7.4

FROM sury-php AS php-8.0.30
RUN sh /usr/local/bin/install-sury-php.sh 8.0
FROM php-8.0.30 AS php-8.0

FROM sury-php AS php-8.1.34
RUN sh /usr/local/bin/install-sury-php.sh 8.1
FROM php-8.1.34 AS php-8.1

FROM php:8.2.35-fpm@sha256:8438f8ea8465dda86393dd84f91da5a02cd5555e494a1000a98112c830669299 AS php-8.2.35
ARG WSC_VERSION
ENV WSC_VERSION=$WSC_VERSION
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"
COPY check-php-version.sh install-extensions.sh start-container.sh /usr/local/bin/
RUN sh /usr/local/bin/install-extensions.sh
ENTRYPOINT ["sh", "-c", "exec bash /usr/local/bin/start-container.sh /wsc \"$WSC_VERSION\""]

FROM php-8.2.35 AS php-8.2

FROM php:8.3.36-fpm@sha256:03af352853b05e35ee15ab898a2755532573684c7d1120b246dbd4e3c90f5007 AS php-8.3.36
ARG WSC_VERSION
ENV WSC_VERSION=$WSC_VERSION
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"
COPY check-php-version.sh install-extensions.sh start-container.sh /usr/local/bin/
RUN sh /usr/local/bin/install-extensions.sh
ENTRYPOINT ["sh", "-c", "exec bash /usr/local/bin/start-container.sh /wsc \"$WSC_VERSION\""]

FROM php-8.3.36 AS php-8.3

FROM php:8.5.12-fpm@sha256:baf3ea13a8207fa18e1011bad1016e8b5e59fc974c6966d0efa6f36a16f875f0 AS php-8.5.12
ARG WSC_VERSION
ENV WSC_VERSION=$WSC_VERSION
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"
COPY check-php-version.sh install-extensions.sh start-container.sh /usr/local/bin/
RUN sh /usr/local/bin/install-extensions.sh
ENTRYPOINT ["sh", "-c", "exec bash /usr/local/bin/start-container.sh /wsc \"$WSC_VERSION\""]

FROM php-8.5.12 AS php-8.5

FROM php:8.4.27-fpm@sha256:212c3c9fc09d58f6b1a12b0b4a6a90fd44a209299a67633c2bccbc1dd53c55e0 AS php-8.4.27
ARG WSC_VERSION
ENV WSC_VERSION=$WSC_VERSION
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"
COPY check-php-version.sh install-extensions.sh start-container.sh /usr/local/bin/
RUN sh /usr/local/bin/install-extensions.sh
ENTRYPOINT ["sh", "-c", "exec bash /usr/local/bin/start-container.sh /wsc \"$WSC_VERSION\""]

FROM php-8.4.27 AS php-8.4
