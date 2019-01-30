FROM ruby:2.6

# Set the locale
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN mkdir /usr/app
WORKDIR /usr/app

ADD Gemfile /usr/app/Gemfile
ADD Gemfile.lock /usr/app/Gemfile.lock
RUN bundle install

ADD . /usr/app

CMD ruby /usr/app/run.rb
