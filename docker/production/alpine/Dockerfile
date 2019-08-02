FROM elixir:1.9-alpine

ENV MIX_ENV=prod

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY lib lib
COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile && \
    mix escript.build
