#!/bin/bash
set -e

# Manual migration runner for production emergencies
# Usage: ./scripts/run-manual-migration.sh [up|down|version]

MIGRATION_COMMAND=${1:-up}

echo "=== Manual Migration Runner ==="
echo "Command: $MIGRATION_COMMAND"
echo ""

PROJECT_ID="personal-portfolio-safehouse"
INSTANCE_NAME="safehouse-db-instance"

PROXY_VERSION=2.8.0
PROXY_BIN=cloud-sql-proxy
PROXY_URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v${PROXY_VERSION}/${PROXY_BIN}.linux.amd64"
PROXY_CHECKSUM=831a5007b6a087c917bf6b46eb7df6289ea37bab7b655c9ed172b8d9e7011e78

echo "=== Checking Google Cloud authentication ==="
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "No active Google Cloud authentication found. Please run:"
    echo "gcloud auth login"
    echo "gcloud auth application-default login"
    exit 1
fi

gcloud config set project "$PROJECT_ID"

echo "=== Fetching configuration from Google Cloud ==="

echo "Verifying Cloud SQL instance..."
if ! gcloud sql instances describe $INSTANCE_NAME --format="value(name)" >/dev/null 2>&1; then
    echo "ERROR: Cloud SQL instance '$INSTANCE_NAME' not found in project '$PROJECT_ID'"
    exit 1
fi

echo "Verifying Secret Manager access..."
if ! gcloud secrets versions access latest --secret="portfolio-safehouse-db-password" >/dev/null 2>&1; then
    echo "ERROR: Cannot access secret 'portfolio-safehouse-db-password'"
    echo "Please ensure your account has Secret Manager access"
    exit 1
fi

echo "All Google Cloud resources verified"

echo "=== Building migration container ==="
docker build -f schema/prod/Dockerfile -t safehouse-migrations:manual .

if ! command -v ${PROXY_BIN} &> /dev/null; then
    echo "Installing Cloud SQL Proxy..."
    curl -o ${PROXY_BIN} "${PROXY_URL}"
    echo "${PROXY_CHECKSUM}  cloud-sql-proxy" | sha256sum -c || {
        echo "ERROR: Checksum verification failed"
        rm -f cloud-sql-proxy
        exit 1
    }
    chmod +x cloud-sql-proxy
    mkdir -p "$HOME/bin"
    mv ${PROXY_BIN} "$HOME/bin/"
    export PATH="$HOME/bin:$PATH"
    echo "Cloud SQL Proxy installed"
fi

echo "=== Running migration: $MIGRATION_COMMAND ==="

docker run --rm \
    -p 5432:5432 \
    -v "$HOME"/.config/gcloud:/root/.config/gcloud:ro \
    safehouse-migrations:manual \
    "$MIGRATION_COMMAND"

echo "=== Migration completed successfully ==="
