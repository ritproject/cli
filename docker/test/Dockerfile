FROM arkye/elixir

ENV MIX_ENV=test

COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile

CMD [ "mix", "test.coverage" ]
