# Build stage
FROM golang:1.14.1-alpine AS builder
COPY ./.git promscale/.git
COPY ./pkg promscale/pkg
COPY ./cmd promscale/cmd
COPY ./go.mod promscale/go.mod
COPY ./go.sum promscale/go.sum
RUN apk update && apk add --no-cache git \
    && cd promscale \
    && go mod download \
    && GIT_COMMIT=$(git rev-list -1 HEAD) \
    && CGO_ENABLED=0 go build -a \
    --ldflags '-w' --ldflags "-X version.CommitHash=$GIT_COMMIT" \
    -o /go/promscale ./cmd/promscale

# Final image
FROM ubuntu:20.04
LABEL maintainer="Timescale https://www.timescale.com"
COPY --from=builder /go/promscale /
RUN apt update && apt install -y ca-certificates
ENTRYPOINT ["/promscale"]
