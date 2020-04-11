FROM ruby:2.6.6

WORKDIR /app

RUN \
    # pg-12 is not available in debian 10
    curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" > /etc/apt/sources.list.d/postgresql.list && \
    \
    # yarn from a package won't install correctly (wrong source, cmdtest is installed instead)
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    \
    apt-get -qq update && \
    apt-get -qq -y install apt-utils postgresql-client-12 nodejs yarn
