#!/bin/sh

# install logic, to prevent overwriting wherever possible
if [ ! -e /var/www/html/.env ]; then
  cp -ar /tmp/kimai/* /var/www/html/
  chown nobody. -R /var/www/html
  cd /var/www/html
  echo "DATABASE_URL=$1" >> /var/www/html/.env
  echo "APP_SECRET=$2" >> /var/www/html/.env
  composer install --no-dev --optimize-autoloader
  bin/console kimai:install -n
  chown nobody.nogroup -R /var/www/html
fi

# This just ensures things are running and this doesn't crash
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
