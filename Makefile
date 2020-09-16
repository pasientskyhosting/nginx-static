DEBIAN_CODE_NAME ?= buster
NGINX_VERSION ?= 1.18.0
NGX_BROTLI_VERSION ?= 0.1.2
BROTLI_VERSION ?= 1.0.7
PCRE_VERSION ?= 8.44
ZLIB_VERSION ?= 1.2.11
OPENSSL_VERSION ?= 1.1.1g
PHP_VERSION ?= 7.3

docker:
	docker build --build-arg DEBIAN_CODE_NAME=$(DEBIAN_CODE_NAME) --build-arg NGINX_VERSION=$(NGINX_VERSION)  --build-arg NGX_BROTLI_VERSION=$(NGX_BROTLI_VERSION) --build-arg BROTLI_VERSION=$(BROTLI_VERSION) --build-arg PCRE_VERSION=$(PCRE_VERSION) --build-arg ZLIB_VERSION=$(ZLIB_VERSION) --build-arg OPENSSL_VERSION=$(OPENSSL_VERSION) --build-arg PHP_VERSION=$(PHP_VERSION) -t pasientskyhosting/nginx-static:$(NGINX_VERSION) .

docker-run:
	docker run pasientskyhosting/nginx-static:$(NGINX_VERSION)

docker-push:
	docker push pasientskyhosting/nginx-static:$(NGINX_VERSION)
