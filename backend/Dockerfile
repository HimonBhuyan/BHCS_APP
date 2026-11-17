FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libcurl4-openssl-dev \
    && docker-php-ext-install pdo_mysql \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html
COPY backend/api/ /var/www/html/

RUN mkdir -p /var/www/uploads \
    && chown -R www-data:www-data /var/www/html /var/www/uploads

CMD ["sh", "-c", "PORT=${PORT:-80}; sed -i \"s/80/$PORT/g\" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf && exec apache2-foreground"]

