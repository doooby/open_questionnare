FROM nginx:stable

COPY app/ops/config/nginx/app.conf /etc/nginx/conf.d/app.conf
RUN rm /etc/nginx/conf.d/default.conf

COPY app/ops/config/nginx/letsencrypt /etc/nginx/letsencrypt

COPY var/www /var/www/app
COPY var/assets /var/www/app/assets
