# schema/railway/Dockerfile
FROM alpine:3.18

ENV MIGRATE_VERSION=4.18.3
ENV MIGRATE_CHECKSUM=60c59c0cac50e99172d95135b2f421863c4b2f4a67709e66daae024d652fa1b5

RUN apk add --no-cache postgresql-client ca-certificates curl && \
    curl -L "https://github.com/golang-migrate/migrate/releases/download/v${MIGRATE_VERSION}/migrate.linux-amd64.tar.gz" -o migrate.tar.gz && \
    echo "${MIGRATE_CHECKSUM}  migrate.tar.gz" | sha256sum -c && \
    tar xvz -f migrate.tar.gz && \
    mv migrate /usr/local/bin/migrate && \
    chmod +x /usr/local/bin/migrate && \
    rm migrate.tar.gz

RUN adduser -D -s /bin/sh migrate-user && \
    mkdir -p /migrations && \
    chown migrate-user:migrate-user /migrations

COPY migrations/ /migrations/
COPY schema/railway/run-migrations.sh ./run-migrations.sh
RUN chmod +x run-migrations.sh && \
    chown migrate-user:migrate-user run-migrations.sh

WORKDIR /
USER migrate-user

# Add health check for better observability
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=1 \
    CMD migrate -path /migrations -database "$DATABASE_URL" version > /dev/null || exit 1

ENTRYPOINT ["./run-migrations.sh"]
CMD ["up"]
