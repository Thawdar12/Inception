FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-cli php-curl php-gd php-mbstring php-xml \
    php-zip php-intl mariadb-client curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on port 9000

RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' \
    /etc/php/8.2/fpm/pool.d/[www.conf](http://www.conf)

# Install WP-CLI

RUN curl -fsSL \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# WordPress document root

WORKDIR /var/www/html

# Copy WordPress setup script

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

CMD ["/usr/local/bin/setup.sh"]
