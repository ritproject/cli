FROM elixir:1.9

ENV MIX_ENV=test

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile

CMD [ "mix", "coveralls" ]
