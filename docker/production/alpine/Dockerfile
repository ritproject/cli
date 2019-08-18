FROM arkye/elixir:alpine

COPY lib lib
COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile && \
    mix escript.build
