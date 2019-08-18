FROM arkye/elixir

COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile

CMD [ "sleep", "infinity" ]
