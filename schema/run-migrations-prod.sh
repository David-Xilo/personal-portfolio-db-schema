#!/bin/sh
set -e

echo "=== Production Migration Runner ==="
echo "Environment: production"

PROJECT_ID="personal-portfolio-safehouse"
INSTANCE_NAME="safehouse-db-instance"
DATABASE_NAME="safehouse_db"
DATABASE_USER="safehouse_db_user"
PASSWORD_SECRET="portfolio-safehouse-db-password"

echo "=== Fetching configuration from Google Cloud ==="

echo "Getting Cloud SQL instance details..."
CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME \
    --project=$PROJECT_ID \
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
        kill $PROXY_PID 2>/dev/null || true
        wait $PROXY_PID 2>/dev/null || true
    fi
}
trap cleanup EXIT

if ! pgrep -f "cloud-sql-proxy.*$CONNECTION_NAME" > /dev/null; then
    echo "Starting Cloud SQL Proxy..."
    cloud-sql-proxy "$CONNECTION_NAME" &
    PROXY_PID=$!
    echo "Cloud SQL Proxy started with PID: $PROXY_PID"

    # Wait for proxy to be ready
    echo "Waiting for proxy to be ready..."
    sleep 10
else
    echo "Cloud SQL Proxy already running"
fi


DATABASE_URL="postgres://${DATABASE_USER}:${DB_PASSWORD}@localhost:5432/${DATABASE_NAME}?sslmode=require"

echo "=== Running migration: ${1:-up} ==="
migrate -path /migrations -database "${DATABASE_URL}" "${1:-up}"

echo "=== Migration completed successfully ==="
