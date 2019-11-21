FROM nginx:stable

RUN rm /etc/nginx/conf.d/default.conf
COPY ops/config/nginx_app.conf /etc/nginx/conf.d/app.conf
