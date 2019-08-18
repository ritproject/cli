FROM ritproject/internal-cli:alpine AS build
FROM erlang:22-alpine

RUN apk add git

WORKDIR /rit

COPY --from=build /app/rit_cli rit

ENTRYPOINT ["./rit"]
