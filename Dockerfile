# Choose a version of Ruby
FROM ruby:2.7.3-slim

ARG APP_NAME=plex_the_ripper
ARG BUNDLER_ARGS
ARG BUNDLE_WITH
ARG BUNDLE_WITHOUT
ARG BUNDLE_DEPLOYMENT

ENV APP_NAME=${APP_NAME}
ENV INSTALL_PATH=/${APP_NAME}
ENV IN_DOCKER=true
ENV NODE_VERSION=v14.6.0
ENV BUNDLER_ARGS=${BUNDLER_ARGS} BUNDLE_WITH=${BUNDLE_WITH} BUNDLE_WITHOUT=${BUNDLE_WITHOUT} BUNDLE_DEPLOYMENT=${BUNDLE_DEPLOYMENT}

RUN set -x
RUN apt-get update -qq
RUN apt-get install -qq -y --no-install-recommends wget libpq-dev clang make ruby-dev libffi-dev libssl-dev
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/*

WORKDIR $INSTALL_PATH

COPY . .

RUN wget -qO /tmp/node.tar.gz "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz"
RUN tar -xzf /tmp/node.tar.gz -C /opt/
RUN rm -f /tmp/node.tar.gz
RUN gem install bundler && bundle install -j "$(getconf _NPROCESSORS_ONLN)" $BUNDLER_ARGS

EXPOSE 3000
RUN ["bin/setup"]
CMD ["rails", "server", "-b", "0.0.0.0"]
