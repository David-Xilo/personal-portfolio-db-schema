# Dockerfile.migrations
# A lightweight container specifically for running database migrations

FROM alpine:latest

# Install golang-migrate and postgresql-client for database connectivity checks
RUN apk add --no-cache curl postgresql-client && \
    curl -L https://github.com/golang-migrate/migrate/releases/latest/download/migrate.linux-amd64.tar.gz | tar xvz && \
    mv migrate /usr/local/bin/migrate && \
    chmod +x /usr/local/bin/migrate && \
    apk del curl

# Copy migration files
COPY migrations /migrations

# Copy your enhanced development script
COPY run-migrations.sh ./run-migrations.sh
RUN chmod +x run-migrations.sh

# Set working directory
WORKDIR /

# Default command runs migrations up
# Can be overridden: docker run <image> down, docker run <image> status, etc.
ENTRYPOINT ["./run-migrations.sh"]
CMD ["up"]
