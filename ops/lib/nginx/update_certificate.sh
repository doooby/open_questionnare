#!/bin/bash
set -e

if [ -z $HOST_NAMES ]; then
  echo "HOST_NAMES is empty"
  echo "you need to set domain names in <stack_path>/stack.conf"
  exit 1
fi

config_dir=/etc/letsencrypt
certs_path=/opt/certs
domains="$(echo $HOST_NAMES | tr ' ' "\n" | sed 's/.*/-d &/' | paste -sd ' ')"

if [ $1 == "renew" ]; then
  certbot certonly --config-dir $config_dir \
      --webroot --webroot-path /var/www/acme_challenge \
      $domains --register-unsafely-without-email --agree-tos \
      --expand --noninteractive
fi

if [ -f $config_dir/live/$domain/privkey.pem ]; then
  cp $config_dir/live/$domain/privkey.pem $certs_path/
  cp $config_dir/live/$domain/fullchain.pem $certs_path/
fi
