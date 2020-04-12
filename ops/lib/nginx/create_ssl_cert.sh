set -e

if [ -z $HOST_NAMES ]; then
  echo "HOST_NAMES is empty"
  echo "you need to set domain names in <stack_path>/stack.conf"
  exit 1
fi

cp ops/etc/nginx/acme-challenge.conf /etc/nginx/conf.d/default.conf
nginx

domains="$(echo $HOST_NAMES | tr ' ' "\n" | sed 's/.*/-d &/' | paste -sd ' ')"
certbot --nginx --register-unsafely-without-email --agree-tos $domains
