FROM ruby:3.3.6-slim AS base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libpq5 libyaml-0-2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev libyaml-dev git && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

ARG BUNDLE_WITHOUT=""
RUN if [ -n "$BUNDLE_WITHOUT" ]; then bundle config set --local without "$BUNDLE_WITHOUT"; fi && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN sed -i 's/\r$//' bin/rails bin/rake bin/setup bin/docker-entrypoint && \
    chmod +x bin/rails bin/rake bin/setup bin/docker-entrypoint && \
    mkdir -p tmp/pids tmp/cache log storage

FROM build AS dev

EXPOSE 3000
ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

FROM base AS runtime

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

ENV RAILS_ENV=production
EXPOSE 3000
ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
