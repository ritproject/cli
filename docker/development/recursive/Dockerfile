FROM ritproject/internal-cli:development

COPY mix.exs mix.lock ./

RUN mix deps.get && \
    mix deps.compile
