FROM ruby:2.7-slim

LABEL maintainer="dev@quintel.com"

RUN apt-get update -yqq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    curl \
    default-libmysqlclient-dev \
    default-mysql-client \
    git \
    gnupg \
    nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*

COPY Gemfile* /app/
WORKDIR /app
RUN bundle install --jobs=4 --retry=3

COPY . /app/

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
