FROM ruby:3.3.6-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev libyaml-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

COPY bin/docker-entrypoint /usr/bin/docker-entrypoint
RUN sed -i 's/\r$//' /usr/bin/docker-entrypoint bin/rails bin/rake bin/setup && \
    chmod +x /usr/bin/docker-entrypoint bin/rails bin/rake bin/setup

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
