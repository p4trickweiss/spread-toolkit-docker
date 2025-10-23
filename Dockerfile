FROM debian:bullseye-slim

# Install 32-bit compatibility libraries and tar
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y libc6:i386 libstdc++6:i386 tar && \
    rm -rf /var/lib/apt/lists/*

# Create directory for Spread
WORKDIR /opt

COPY spread-bin-4.0.0.tar.gz /opt/spread-bin-4.0.0.tar.gz

RUN tar -xzf spread-bin-4.0.0.tar.gz && \
    rm spread-bin-4.0.0.tar.gz

# Create the 'spread' user and group
RUN groupadd -r spread && \
    useradd -r -g spread spread && \
    chown -R spread:spread /opt/spread-bin-4.0.0

# Set environment variables
ENV SPREAD_HOME=/opt/spread-bin-4.0.0
ENV PATH=$SPREAD_HOME/bin/i686-pc-linux-gnu:$PATH

# Copy and configure spread.conf
COPY conf/spread.conf /etc/spread/spread.conf
RUN chown spread:spread /etc/spread/spread.conf

# Expose Spread default port
EXPOSE 4803

# Run Spread as the 'spread' user by default
USER spread

ENTRYPOINT [ "spread", "-c", "/etc/spread/spread.conf" ]
