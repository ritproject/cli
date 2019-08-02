FROM registry.gitlab.com/ritproject/cli:development

COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile
