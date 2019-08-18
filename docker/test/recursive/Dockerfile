FROM ritproject/internal-cli:test

COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile
