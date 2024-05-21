# syntax=docker/dockerfile:1.4
FROM alpine:latest
RUN apk add --no-cache rsync
RUN <<EOR
addgroup -S run --gid 1234
adduser --disabled-password --no-create-home --uid 1234 run -G run
EOR
