FROM registry.gitlab.com/ritproject/cli:alpine AS build
FROM erlang:22-alpine

RUN apk add git

WORKDIR /rit

COPY --from=build /app/rit rit

ENTRYPOINT ["./rit"]
