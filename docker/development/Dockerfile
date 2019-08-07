FROM elixir:1.9

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile

CMD [ "bash" ]
