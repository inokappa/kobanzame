FROM ruby:2.6-alpine
RUN apk update && apk add --no-cache bash vim git
WORKDIR /app
ADD . /app/
RUN gem install pkg/kobanzame-0.0.6.gem
