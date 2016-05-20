FROM alpine:edge
MAINTAINER Francis Robichaud <frobichaud@petalmd.com>

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /app
WORKDIR /app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /app
CMD ["bundle", "exec", "ruby", "/usr/src/app/gitlab-automerge-on-webhook.rb"]
