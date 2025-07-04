FROM google/cloud-sdk:alpine

ENV MIGRATE_VERSION=4.18.3
ENV PROXY_VERSION=2.8.0
ENV MIGRATE_CHECKSUM=60c59c0cac50e99172d95135b2f421863c4b2f4a67709e66daae024d652fa1b5
ENV PROXY_CHECKSUM=831a5007b6a087c917bf6b46eb7df6289ea37bab7b655c9ed172b8d9e7011e78

RUN apk add --no-cache postgresql-client ca-certificates curl && \
    curl -L "https://github.com/golang-migrate/migrate/releases/download/v${MIGRATE_VERSION}/migrate.linux-amd64.tar.gz" -o migrate.tar.gz && \
    echo "${MIGRATE_CHECKSUM}  migrate.tar.gz" | sha256sum -c && \
    tar xvz -f migrate.tar.gz && \
    mv migrate /usr/local/bin/migrate && \
    chmod +x /usr/local/bin/migrate && \
    rm migrate.tar.gz

RUN curl -L "https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v${PROXY_VERSION}/cloud-sql-proxy.linux.amd64" -o cloud-sql-proxy && \
    echo "${PROXY_CHECKSUM}  cloud-sql-proxy" | sha256sum -c && \
    chmod +x cloud-sql-proxy && \
    mv cloud-sql-proxy /usr/local/bin/ && \
    apk del curl

RUN adduser -D -s /bin/sh migrate-user && \
    mkdir -p /migrations && \
    chown migrate-user:migrate-user /migrations

COPY migrations /migrations
COPY run-migrations-prod.sh ./run-migrations-prod.sh
RUN chmod +x run-migrations-prod.sh

USER migrate-user
WORKDIR /

ENTRYPOINT ["./run-migrations-prod.sh"]
CMD ["up"]