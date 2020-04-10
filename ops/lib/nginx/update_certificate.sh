#!/bin/bash
set -e

if [ -z $SERVER_NAMES ]; then
  echo "SERVER_NAMES is empty"
  echo "you need to set domain names in <stack_path>/ops_stack.conf"
  exit 1
fi

config_dir=/etc/letsencrypt
certs_path=/opt/certs
domains="$(echo $SERVER_NAMES | tr ' ' "\n" | sed 's/.*/-d &/' | paste -sd ' ')"

if [ $1 == "renew" ]; then
  certbot certonly --config-dir $config_dir \
      --webroot --webroot-path /var/www/certbot \
      $domains --register-unsafely-without-email --agree-tos \
      --expand --noninteractive
fi

if [ -f $config_dir/live/$domain/privkey.pem ]; then
  cp $config_dir/live/$domain/privkey.pem $certs_path/
  cp $config_dir/live/$domain/fullchain.pem $certs_path/
fi
