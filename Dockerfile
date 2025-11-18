# Build stage
FROM debian:bullseye-slim AS builder

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY spread-src-4.0.0 /build/spread-src-4.0.0

# Build and install to /spread
RUN cd spread-src-4.0.0 && \
    if [ "$TARGETARCH" = "amd64" ]; then \
    BUILD_TYPE="x86_64-pc-linux-gnu"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    BUILD_TYPE="aarch64-unknown-linux-gnu"; \
    else \
    BUILD_TYPE="$(uname -m)-unknown-linux-gnu"; \
    fi && \
    ./configure --build=$BUILD_TYPE --prefix=/spread && \
    make CFLAGS="-fcommon" && \
    make install

# Runtime stage
FROM debian:bullseye-slim

# Install only runtime dependencies if needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libc6 \
    && rm -rf /var/lib/apt/lists/*

# Create spread user and group
RUN groupadd -r spread && \
    useradd -r -g spread spread

# Create directory structure
RUN mkdir -p /spread/bin /spread/sbin /spread/etc

# Copy only necessary binaries and config from builder stage
COPY --from=builder /spread/bin /spread/bin
COPY --from=builder /spread/sbin /spread/sbin
COPY --from=builder /spread/etc /spread/etc

# Copy default configuration
COPY conf/spread.conf /spread/etc/spread.conf

# Set proper permissions
RUN chown -R spread:spread /spread && \
    chmod 755 /spread/bin/* /spread/sbin/* && \
    chmod 644 /spread/etc/*

EXPOSE 4803

USER spread

ENTRYPOINT ["/spread/sbin/spread", "-c", "/spread/etc/spread.conf"]
