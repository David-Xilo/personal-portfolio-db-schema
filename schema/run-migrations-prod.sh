#!/bin/sh
set -e

echo "=== Production Migration Runner ==="
echo "Environment: production"

PROJECT_ID="personal-portfolio-safehouse"
INSTANCE_NAME="safehouse-db-instance"
DATABASE_NAME="safehouse_db"
DATABASE_USER="safehouse_db_user"
PASSWORD_SECRET="portfolio-safehouse-db-password"


PROXY_VERSION=2.8.0
PROXY_BIN=cloud-sql-proxy
PROXY_URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v${PROXY_VERSION}/${PROXY_BIN}.linux.amd64"
PROXY_CHECKSUM=831a5007b6a087c917bf6b46eb7df6289ea37bab7b655c9ed172b8d9e7011e78


echo "=== Fetching configuration from Google Cloud ==="

echo "Getting Cloud SQL instance details..."
CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME \
    --project="${PROJECT_ID}" \
    --format="value(connectionName)")

if [ -z "$CONNECTION_NAME" ]; then
    echo "ERROR: Could not get connection name for instance $INSTANCE_NAME"
    exit 1
fi
echo "Connection name: $CONNECTION_NAME"

echo "Fetching database password from Secret Manager..."
DB_PASSWORD=$(gcloud secrets versions access latest \
    --secret="$PASSWORD_SECRET" \
    --project="$PROJECT_ID")

if [ -z "$DB_PASSWORD" ]; then
    echo "ERROR: Could not retrieve password from Secret Manager"
    exit 1
fi
echo "Database password retrieved successfully"

echo "=== Setting up Cloud SQL Proxy connection ==="
PROXY_PID=""

cleanup() {
    if [ -n "$PROXY_PID" ]; then
        echo "Cleaning up Cloud SQL Proxy (PID: $PROXY_PID)..."
        kill "$PROXY_PID" 2>/dev/null || true
        wait "$PROXY_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

if ! command -v "${PROXY_BIN}" > /dev/null; then
  echo "Installing Cloud SQL Proxy v${PROXY_VERSION}"

  curl -fsSL "${PROXY_URL}" -o "${PROXY_BIN}"

  echo "${PROXY_CHECKSUM}  ${PROXY_BIN}" | sha256sum -c --quiet - \
    || {
      echo >&2 "ERROR: checksum mismatch for ${PROXY_BIN}"
      rm -f "${PROXY_BIN}"
      exit 1
    }

  chmod +x "${PROXY_BIN}"
  mkdir -p "$HOME/bin"
  mv "${PROXY_BIN}" "$HOME/bin/"
  export PATH="$HOME/bin:$PATH"
  echo "Cloud SQL Proxy installed (v${PROXY_VERSION})"
  sleep 5
else
    echo "Cloud SQL Proxy already available"
fi

echo "=== Starting Cloud SQL Proxy ==="
${PROXY_BIN} --instances="${CONNECTION_NAME}"=tcp:5432 &
PROXY_PID=$!
echo "Cloud SQL Proxy started (PID: $PROXY_PID)"
sleep 5

echo "=== Running migration: ${1:-up} ==="
export PGPASSWORD="${DB_PASSWORD}"
migrate -path /migrations -database "postgres://${DATABASE_USER}@localhost:5432/${DATABASE_NAME}?sslmode=require" "${1:-up}"

echo "=== Migration completed successfully ==="
