FROM app:base

ENV RAILS_ENV=production

COPY var/bundle /usr/local/bundle
#COPY var/node_modules ./node_modules
