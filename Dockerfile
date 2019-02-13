FROM php:7-apache
MAINTAINER Michael Friedrich <Michael.Friedrich@gmx.de>

EXPOSE 80

ARG DEBIAN_FRONTEND=noninteractive

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip git sudo libpng-dev zlib1g-dev libicu-dev g++ \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  && docker-php-ext-configure gd \
  && docker-php-ext-install gd \
  && docker-php-ext-configure zip \
  && docker-php-ext-install zip \
  && rm -rf /var/lib/apt/lists/*


RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php --quiet \
  && rm composer-setup.php \
  && mv composer.phar /usr/local/bin/composer


RUN mkdir -p /var/www \
  && cd /var/www \
  && git clone https://github.com/kevinpapst/kimai2.git \
  && cd kimai2 \
  && chown -R www-data:www-data /var/www \
  && chown -R :www-data . \
  && chmod -R g+r . \
  && chmod -R g+rw var/ \
  && cp .env.dist .env \
  && sudo -u www-data composer install --no-dev --optimize-autoloader

RUN  cd /var/www/kimai2 \
  && bin/console doctrine:database:create \
  && bin/console doctrine:schema:create \
  && bin/console doctrine:migrations:version --add --all \
  && bin/console cache:warmup --env=prod \
  && bin/console kimai:create-user username admin@example.com ROLE_SUPER_ADMIN admin \
  && chmod 777 /var/www/kimai2/var/data/kimai.sqlite

VOLUME /var/www/kimai2/var/data
