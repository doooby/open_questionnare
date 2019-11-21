FROM ruby:2.6.5

RUN mkdir /app
WORKDIR /app
ENV RAILS_ENV=production

COPY . .
RUN bash ops/lib/provision_container.sh
