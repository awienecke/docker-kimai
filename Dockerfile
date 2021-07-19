FROM alpine:3.13
ENV DATABASE_URL "mysql://user:password@localhost/database"
ENV APP_SECRET "239hfl32bof2092b0fih"
LABEL Maintainer="Jabar Digital Service <digital.service@jabarprov.go.id>" \
      Description="Lightweight container with Nginx 1.16 & PHP-FPM 7.4 based on Alpine Linux (forked from trafex/alpine-nginx-php7)."

#ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# make sure you can use HTTPS
#RUN apk --update add ca-certificates

#RUN echo "https://dl.bintray.com/php-alpine/v3.11/php-7.4" >> /etc/apk/repositories

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-opcache php7-openssl php7-curl \
    nginx supervisor curl

# https://github.com/codecasts/php-alpine/issues/21 *resolved*
# RUN ln -s /usr/bin/php7 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Remove default server definition
RUN rm /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html
RUN apk add --no-cache git composer bash freetype haveged icu libldap libpng libzip libxslt-dev php7-zip php7-xml php7-tokenizer php7-fileinfo php7-simplexml \
        php7-xmlwriter php7-mysqli php7-gd php7-intl php7-pdo php7-xsl php7-ctype php7-zlib php7-xmlreader php7-session php7-pdo_mysql php7-mysqlnd &&\
    git clone -b 1.12 --depth 1 https://github.com/kevinpapst/kimai2.git &&\
    mv /var/www/html/ /var/www/html.old && mv kimai2 /tmp/kimai

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN if [ ! -e /var/www/html ]; then mkdir -p /var/www/html ; fi
RUN chown -R nobody.nogroup /var/www/html && \
  chown -R nobody.nogroup /tmp/kimai && \
  chown -R nobody.nogroup /run && \
  chown -R nobody.nogroup /var/lib/nginx && \
  chown -R nobody.nogroup /var/log/nginx

# Switch to use a non-root user from here on
#USER nobody

# Add application
#WORKDIR /var/www/html
#COPY --chown=nobody src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080
COPY start.sh /start.sh
# Let supervisord start nginx & php-fpm
CMD ["/bin/sh", "-c", "/start.sh $DATABASE_URL $APP_SECRET"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
