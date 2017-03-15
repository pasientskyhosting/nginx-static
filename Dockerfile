FROM nginx:1.11.10-alpine
MAINTAINER Andreas Krüger <ak@patientsky.com>

RUN apk update && \
    apk add --no-cache bash \
    openssh-client \
    supervisor \
    git && \
#    mkdir -p /etc/nginx && \
#    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor

ADD conf/supervisord.conf /etc/supervisord.conf

# Copy our nginx config
# RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    mkdir -p /var/www/html/

ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf

RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# Add Scripts
ADD scripts/start.sh /start.sh
RUN chmod 755 /start.sh

# copy in code
ADD errors /var/www/errors/

EXPOSE 80

CMD ["/start.sh"]
