FROM google/cloud-sdk:529.0.0-alpine

ENV MIGRATE_VERSION=4.18.3
ENV MIGRATE_CHECKSUM=60c59c0cac50e99172d95135b2f421863c4b2f4a67709e66daae024d652fa1b5

# Install required tools including netcat for proxy readiness checks and keep curl for runtime
RUN apk add --no-cache postgresql-client ca-certificates curl netcat-openbsd && \
    curl -L "https://github.com/golang-migrate/migrate/releases/download/v${MIGRATE_VERSION}/migrate.linux-amd64.tar.gz" -o migrate.tar.gz && \
    echo "${MIGRATE_CHECKSUM}  migrate.tar.gz" | sha256sum -c && \
    tar xvz -f migrate.tar.gz && \
    mv migrate /usr/local/bin/migrate && \
    chmod +x /usr/local/bin/migrate && \
    rm migrate.tar.gz

RUN adduser -D -s /bin/sh migrate-user && \
    mkdir -p /migrations && \
    chown migrate-user:migrate-user /migrations

COPY schema/migrations /migrations
COPY schema/run-migrations-prod.sh ./run-migrations-prod.sh
RUN chmod +x run-migrations-prod.sh

WORKDIR /

ENTRYPOINT ["./run-migrations-prod.sh"]
CMD ["up"]
