FROM debian:12

#installation
RUN apt-get update & apt-get install -y \
    curl \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client

RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && rm latest.tar.gz \
    && mv wordpress /var/www/html