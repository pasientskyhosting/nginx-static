ARG DEBIAN_CODE_NAME
FROM debian:$DEBIAN_CODE_NAME-slim

LABEL maintainer "Chad Jones <cj@patientsky.com>"

ARG NGINX_VERSION
ARG PCRE_VERSION
ARG ZLIB_VERSION
ARG OPENSSL_VERSION
ARG NGX_BROTLI_VERSION
ARG BROTLI_VERSION
ARG PHP_VERSION

ARG CONFIG="\
    --with-cc-opt='-fstack-protector-all' \
    --with-ld-opt='-Wl,-z,relro,-z,now' \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/tmp/nginx.pid \
    --http-log-path=/dev/stdout \
    --error-log-path=/dev/stderr \
    --http-client-body-temp-path=/tmp/client_temp \
    --http-proxy-temp-path=/tmp/proxy_temp \
    --http-fastcgi-temp-path=/tmp/fastcgi_temp \
    --http-uwsgi-temp-path=/tmp/uwsgi_temp \
    --http-scgi-temp-path=/tmp/scgi_temp \
    --add-module=/tmp/ngx_brotli-$NGX_BROTLI_VERSION \
    --with-pcre=/tmp/pcre-$PCRE_VERSION \
    --with-openssl=/tmp/openssl-$OPENSSL_VERSION \
    --with-zlib=/tmp/zlib-$ZLIB_VERSION \
    --with-file-aio \
    --with-http_v2_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads"

ADD https://github.com/google/brotli/archive/v$BROTLI_VERSION.tar.gz /tmp/brotli.tar.gz
ADD https://github.com/eustas/ngx_brotli/archive/v$NGX_BROTLI_VERSION.tar.gz /tmp/ngx_brotli.tar.gz
ADD https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VERSION.tar.gz /tmp/pcre.tar.gz
ADD https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz /tmp/openssl.tar.gz
ADD https://zlib.net/zlib-$ZLIB_VERSION.tar.gz /tmp/zlib.tar.gz
ADD https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz /tmp/nginx.tar.gz

RUN tar -C /tmp -xf /tmp/pcre.tar.gz && \
    tar -C /tmp -xf /tmp/zlib.tar.gz && \
    tar -C /tmp -xf /tmp/openssl.tar.gz && \
    tar -C /tmp -xf /tmp/brotli.tar.gz && \
    tar -C /tmp -xf /tmp/ngx_brotli.tar.gz && \
    tar -C /tmp -xf /tmp/nginx.tar.gz && \
    mv /tmp/brotli-$BROTLI_VERSION/* /tmp/ngx_brotli-$NGX_BROTLI_VERSION/deps/brotli && \
    apt update && \
    apt install -y gcc g++ perl make ca-certificates && \
    cd /tmp/nginx-$NGINX_VERSION && \
    ./configure $CONFIG && \
    make && make install

RUN cp /tmp/nginx-$NGINX_VERSION/objs/nginx /

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y -q --install-recommends --no-install-suggests \
    bash \
    openssh-client \
    supervisor \
    brotli \
    php$PHP_VERSION-cli \
    php$PHP_VERSION-curl \
    php$PHP_VERSION-json \
    tzdata \
    curl \
    libjemalloc-dev \
    git && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/log/supervisor

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so
ADD conf/supervisord.conf /etc/supervisord.conf

# Copy our nginx config
# RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    mkdir -p /var/www/html/ && \
    touch /etc/nginx/csp.inc.conf

ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf

RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# Add Scripts
ADD scripts/start.sh /start.sh
RUN chmod 755 /start.sh

# copy in code
ADD errors /var/www/errors/

EXPOSE 80

CMD ["/start.sh"]
