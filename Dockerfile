FROM golang:1.14-alpine AS build-env

# Set up dependencies
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3

# Set working directory for the build
WORKDIR /go/src/app

# Add source files
COPY . .

RUN go version

# Install minimum necessary dependencies, build persistenceCore, remove packages
RUN apk add --no-cache $PACKAGES \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -y | sh

# Install wasmd
RUN git clone https://github.com/CosmWasm/wasmd.git \
    && cd wasmd \
    && git checkout v0.10.0 \
    && make install

RUN make build

# Final image
FROM alpine:edge

# Install ca-certificates
RUN apk add --update ca-certificates

# Create appuser
ENV USER=appuser
ENV UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/app" \
    --shell "/sbin/nologin" \
    --uid "${UID}" \
    "${USER}"
USER 10001

WORKDIR /app

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/assetClient /usr/bin/assetClient
COPY --from=build-env /go/bin/assetNode /usr/bin/assetNode

# Run persistenceCore by default, omit entrypoint to ease using container with cli
CMD ["assetClient"]
