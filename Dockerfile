FROM alpine:3.2

ONBUILD RUN bundle config --global jobs $(grep processor /proc/cpuinfo | tail -n1 | awk -F: '{ print $2 + 1 }')

RUN apk update && apk add ca-certificates=20141019-r2 && apk add build-base

ENV RUBY_VERSION 2.2.3

RUN cd /tmp \
	&& wget -O - https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz | tar xzf - \
	&& cd ruby-install-0.5.0 \
	&& make install \
	&& cd - \
	&& rm -rf /tmp/v0.5.0.tar.gz /tmp/ruby-install-0.5.0 \
	&& apk add -t ruby-deps libc-dev=0.7-r0 readline-dev=6.3.008-r0 libffi-dev=3.2.1-r0 \
       "openssl-dev>1.0.2" gdbm-dev=1.11-r0 zlib-dev=1.2.8-r1 bash=4.3.33-r0 \
    && ruby-install ruby $RUBY_VERSION -- --disable-install-rdoc \
    #&& apk del build-base ruby-deps \
    && rm -r /usr/local/src/ruby-${RUBY_VERSION}*

RUN mkdir -p /opt/rubies/ruby-${RUBY_VERSION}/etc \
    && echo 'gem: --no-document' > /opt/rubies/ruby-${RUBY_VERSION}/etc/gemrc

ENV PATH /opt/rubies/ruby-${RUBY_VERSION}/bin:$PATH

RUN gem install bundler

ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH

RUN bundle config --global path "$GEM_HOME"       \
    && bundle config --global bin "$GEM_HOME/bin" \
    && bundle config --global frozen 1            \
    && bundle config --global retry 3

ENV BUNDLE_APP_CONFIG $GEM_HOME

ADD . /app
WORKDIR /app

RUN bundle install

ENTRYPOINT ["ruby", "app.rb"]