FROM ruby:2.6.5

# yarn from a package won't install correctly (wrong source, cmdtest is installed instead)
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && \
    apt-get install -y apt-utils postgresql-client nodejs yarn

COPY app /app
WORKDIR /app

ENV RAILS_ENV=production
