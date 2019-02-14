FROM php:7-apache
MAINTAINER Michael Friedrich <Michael.Friedrich@gmx.de>

ARG DEBIAN_FRONTEND=noninteractive

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip git zip \
    libpng-dev libicu-dev libzip-dev sudo \
  && docker-php-ext-install intl \
  && docker-php-ext-install gd \
  && docker-php-ext-install zip \
  && docker-php-ext-install pdo \
  && docker-php-ext-install pdo_mysql \
  && rm -rf /var/lib/apt/lists/*


RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php --quiet \
  && rm composer-setup.php \
  && mv composer.phar /usr/local/bin/composer


RUN mkdir -p /var/www \
  && cd /var/www \
  && git clone https://github.com/agileit/kimai2.git \
  && cd kimai2 \
  && chown -R www-data:www-data /var/www \
  && chown -R :www-data . \
  && chmod -R g+r . \
  && chmod -R g+rw var/ \
  && sudo -u www-data composer install --no-dev --optimize-autoloader

USER www-data

COPY .env /var/www/kimai2/.env

USER root

COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh

CMD ["bash","/entrypoint.sh"]
