FROM app:base

COPY ./var/bundle /usr/local/bundle
COPY ./var/node_modules ./node_modules
