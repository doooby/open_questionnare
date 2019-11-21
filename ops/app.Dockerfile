FROM ruby:2.6.5

RUN mkdir /app
WORKDIR /app

COPY . .

RUN cp ops/lib/cron_logrotate.sh /etc/cron.daily/app && \
        chmod +x /etc/cron.daily/app && \
        cp ops/config/logrotate_app.conf /etc/logrotate.conf
