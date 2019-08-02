FROM registry.gitlab.com/ritproject/cli:alpine-release

COPY lib lib
COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile && \
    mix escript.build
