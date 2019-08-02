FROM registry.gitlab.com/ritproject/cli:test

COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile
