FROM nginx:1.27.3-alpine
LABEL maintainer="Sascha Greuel <sascha@softcreatr.de>"

RUN apk add --no-cache \
      build-base \
      pcre-dev \
      zlib-dev \
      openssl-dev \
      linux-headers \
      curl \
      git

ENV NGINX_VERSION 1.27.3

RUN mkdir -p /usr/src && \
    cd /usr/src && \
    curl -fSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz && \
    tar -zxvf nginx.tar.gz

RUN cd /usr/src && \
    git clone https://github.com/openresty/headers-more-nginx-module.git

RUN cd /usr/src/nginx-${NGINX_VERSION} && \
    ./configure --with-compat --add-dynamic-module=../headers-more-nginx-module && \
    make modules && \
    cp objs/ngx_http_headers_more_filter_module.so /etc/nginx/modules/ && \
    rm -rf /usr/src
