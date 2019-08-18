FROM ritproject/internal-cli:alpine

COPY lib lib
COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile && \
    mix escript.build
