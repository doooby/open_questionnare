FROM nginx:stable

COPY config/nginx_app.conf /etc/nginx/conf.d/app.conf
RUN rm /etc/nginx/conf.d/default.conf

COPY app/var/www /var/www/app
COPY app/var/assets /var/www/app/assets
