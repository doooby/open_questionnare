set -e

cp app/ops/lib/nginx/acme-challenge.conf /etc/nginx/conf.d/default.conf
nginx

domain="$(cat /etc/letsencrypt/domain_name)"
certbot --nginx --register-unsafely-without-email --agree-tos -d $domain
