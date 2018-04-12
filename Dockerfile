FROM ruby:2.5.0-stretch
MAINTAINER tdtds <t@tdtds.jp>

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - \
	 && apt install -y nodejs openjdk-8-jre \
	 && apt -y clean \
    && echo -e "install: --no-document\nupdate: --no-document" >/etc/gemrc \
    && mkdir -p /opt/massr

ENV LANG=ja_JP.utf8
ENV RACK_ENV=production
WORKDIR /opt/massr
COPY [ ".", "/opt/massr/" ]
RUN bundle --path=vendor/bundle --without=development:test --jobs=4 --retry=3 \
    && bundle exec rake assets:precompile

EXPOSE 9393
ENTRYPOINT ["bundle", "exec", "puma", "--port", "9393"]
