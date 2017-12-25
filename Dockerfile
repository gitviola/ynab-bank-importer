FROM ruby:2.4.1

MAINTAINER Martin Schurig <martin@schurig.pw>

# Set the locale
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN git clone https://github.com/schurig/ruby_fints.git && cd ruby_fints && git checkout ing-diba && gem build ruby_fints.gemspec && gem install ruby_fints-0.0.1.gem
# original: https://github.com/playtestcloud/ruby_fints.git

RUN mkdir /usr/app
WORKDIR /usr/app

ADD Gemfile /usr/app/Gemfile
ADD Gemfile.lock /usr/app/Gemfile.lock
RUN bundle install

ADD . /usr/app

CMD ruby /usr/app/run.rb
