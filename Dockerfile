FROM alpine:edge
MAINTAINER Francis Robichaud <frobichaud@petalmd.com>

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

RUN apk add --update --no-cache $BUILD_PACKAGES $RUBY_PACKAGES

RUN mkdir /app
WORKDIR /app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /app
CMD ["bundle", "exec", "ruby", "/usr/src/app/github-automerge-on-webhook.rb"]
