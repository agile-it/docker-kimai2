#!/bin/#!/usr/bin/env bash

cd /var/www/kimai2
sudo -u www-data bin/console doctrine:database:create
sudo -u www-data bin/console doctrine:schema:create
sudo -u www-data bin/console doctrine:migrations:version --add --all
sudo -u www-data bin/console cache:warmup --env=prod
APP_ENV=prod APP_DEBUG=0 apache2-foreground
