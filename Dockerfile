FROM ruby:alpine
MAINTAINER Francis Robichaud <frobichaud@petalmd.com>

ENV RUBY_PACKAGES ruby-bundler

RUN apk add --update --no-cache $BUILD_PACKAGES $RUBY_PACKAGES

USER petal
RUN mkdir /app
WORKDIR /app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /app
CMD ["bundle", "exec", "ruby", "/usr/src/app/github-automerge-on-webhook.rb"]
