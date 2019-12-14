FROM app:base

ENV RAILS_ENV=production

COPY app .
COPY assets public/assets

COPY bundle /usr/local/bundle
COPY node_modules node_modules
