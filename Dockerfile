FROM golang:1.25.11-alpine AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY services ./services

ARG SERVICE
RUN test -n "$SERVICE" \
    && CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/service "./services/${SERVICE}"

FROM alpine:3.21

RUN addgroup -S app && adduser -S -G app app

COPY --from=build --chown=app:app /out/service /service

USER app

ENTRYPOINT ["/service"]
