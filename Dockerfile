FROM ruby:2.6-slim-buster

LABEL maintainer="weex"
LABEL source="https://github.com/magicstone-dev/acropolis"

ENV RAILS_ENV=production \
    UID=942 \
    GID=942

RUN apt-get update \
    && apt-get install -y \
    build-essential \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libxslt-dev \
    imagemagick \
    ghostscript \
    curl \
    libmagickwand-dev \
    git \
    libpq-dev \
    default-libmysqlclient-dev \
    nodejs \
    wget \
    libjemalloc-dev \
    gosu \
    libidn11-dev \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --GID ${GID} diaspora \
    && adduser --uid ${UID} --gid ${GID} \
    --home /diaspora --shell /bin/sh \
    --disabled-password --gecos "" diaspora


USER diaspora

WORKDIR /diaspora
RUN git clone --depth 1 https://github.com/magicstone-dev/acropolis.git
RUN mv /diaspora/diaspora/* /diaspora/
RUN cp config/database.yml.example config/database.yml

RUN gem install bundler \
    && script/configure_bundler \
    && bin/bundle config --local with postgresql mysql \
    && bin/bundle install --full-index -j$(getconf _NPROCESSORS_ONLN)

VOLUME /diaspora/public
