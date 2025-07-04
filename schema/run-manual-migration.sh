#!/bin/bash
set -e

# Manual migration runner for production emergencies
# Usage: ./scripts/run-manual-migration.sh [up|down|version]

MIGRATION_COMMAND=${1:-up}

echo "=== Manual Migration Runner ==="
echo "Command: $MIGRATION_COMMAND"
echo ""

# Configuration
PROJECT_ID="personal-portfolio-safehouse"
INSTANCE_NAME="safehouse-db-instance"

echo "=== Checking Google Cloud authentication ==="
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "No active Google Cloud authentication found. Please run:"
    echo "gcloud auth login"
    echo "gcloud auth application-default login"
    exit 1
fi

# Set the project
gcloud config set project "$PROJECT_ID"

echo "=== Fetching configuration from Google Cloud ==="

# Verify Cloud SQL instance exists
echo "Verifying Cloud SQL instance..."
if ! gcloud sql instances describe $INSTANCE_NAME --format="value(name)" >/dev/null 2>&1; then
    echo "ERROR: Cloud SQL instance '$INSTANCE_NAME' not found in project '$PROJECT_ID'"
    exit 1
fi

# Verify Secret Manager access
echo "Verifying Secret Manager access..."
if ! gcloud secrets versions access latest --secret="portfolio-safehouse-db-password" >/dev/null 2>&1; then
    echo "ERROR: Cannot access secret 'portfolio-safehouse-db-password'"
    echo "Please ensure your account has Secret Manager access"
    exit 1
fi

echo "✅ All Google Cloud resources verified"

echo "=== Building migration container ==="
docker build -f schema/prod/Dockerfile -t safehouse-migrations:manual .

# Check if cloud-sql-proxy is available
if ! command -v cloud-sql-proxy &> /dev/null; then
    echo "Installing Cloud SQL Proxy..."
    curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.7.0/cloud-sql-proxy.linux.amd64
    chmod +x cloud-sql-proxy
    sudo mv cloud-sql-proxy /usr/local/bin/
    echo "Cloud SQL Proxy installed"
fi

echo "=== Running migration: $MIGRATION_COMMAND ==="
# Run migration container with Google Cloud credentials mounted
docker run --rm \
    --network host \
    -v "$HOME"/.config/gcloud:/root/.config/gcloud:ro \
    safehouse-migrations:manual \
    "$MIGRATION_COMMAND"

echo "=== Migration completed successfully ==="
