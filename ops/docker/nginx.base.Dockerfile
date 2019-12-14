FROM nginx:stable

RUN apt-get -qq update && \
    apt-get -qq -y install certbot python-certbot-nginx inotify-tools

RUN mkdir -p /var/www/certbot
WORKDIR /opt
