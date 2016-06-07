FROM ruby:alpine
MAINTAINER Francis Robichaud <frobichaud@petalmd.com>

ENV RUBY_PACKAGES ruby-bundler

RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

USER petal
RUN mkdir /app
WORKDIR /app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /app
CMD ["bundle", "exec", "ruby", "/usr/src/app/github-automerge-on-webhook.rb"]
