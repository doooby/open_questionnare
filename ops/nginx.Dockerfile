FROM nginx:stable

COPY config/nginx_app.conf /etc/nginx/conf.d/app.conf
RUN rm /etc/nginx/conf.d/default.conf

COPY lib/cron_logrotate.sh /etc/cron.daily/app
COPY config/logrotate_nginx.conf /etc/logrotate.conf
RUN chmod +x /etc/cron.daily/app
