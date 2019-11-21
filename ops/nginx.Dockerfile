FROM nginx:stable

COPY ops/config/nginx_app.conf /etc/nginx/conf.d
