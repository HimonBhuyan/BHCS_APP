FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libcurl4-openssl-dev \
    && docker-php-ext-install pdo_mysql \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html
COPY backend/api/ /var/www/html/

RUN mkdir -p /var/www/uploads \
    && chown -R www-data:www-data /var/www/html /var/www/uploads \
    && printf "upload_max_filesize=20M\npost_max_size=25M\nmemory_limit=256M\n" > /usr/local/etc/php/conf.d/uploads.ini \
    && printf "<Directory /var/www/html>\n    AllowOverride All\n    FallbackResource /index.php\n</Directory>\n" > /etc/apache2/conf-available/bh-app.conf \
    && a2enconf bh-app

CMD ["sh", "-c", "mkdir -p /var/www/uploads && chown -R www-data:www-data /var/www/uploads && PORT=${PORT:-80}; sed -i \"s/Listen 80/Listen $PORT/g\" /etc/apache2/ports.conf && sed -i \"s/:80>/:$PORT>/g\" /etc/apache2/sites-available/000-default.conf && exec apache2-foreground"]

