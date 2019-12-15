#!/bin/bash

set -e

le_path=/etc/letsencrypt
certs_path=/opt/certs
domain="$(cat $le_path/domain_name)"

if [ $1 == "renew" ]; then
  certbot certonly --config-dir $le_path --agree-tos --domains $domain --register-unsafely-without-email --expand --noninteractive --webroot --webroot-path /var/www/certbot
fi

if [ -f $le_path/live/$domain/privkey.pem ]; then
  cp $le_path/live/$domain/privkey.pem $certs_path/
  cp $le_path/live/$domain/fullchain.pem $certs_path/
fi
