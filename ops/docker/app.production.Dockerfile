FROM app:base

ENV RAILS_ENV=production

COPY app .

COPY bundle /usr/local/bundle
COPY node_modules node_modules
