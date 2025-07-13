#!/bin/sh
set -e

echo "=== Safehouse Migration Runner (Cloud SQL Proxy - Unix Socket) ==="

MIGRATION_COMMAND=${1:-up}
echo "Migration command: $MIGRATION_COMMAND"

# Validate required environment variables
REQUIRED_VARS="PROJECT_ID INSTANCE_NAME DATABASE_NAME DATABASE_USER PASSWORD_SECRET"
for VAR in $REQUIRED_VARS; do
  eval VAL=\$"$VAR"
  if [ -z "$VAL" ]; then
    echo "ERROR: Environment variable $VAR is not set."
    exit 1
  fi
done

echo "Project ID: $PROJECT_ID"
echo "Instance: $INSTANCE_NAME"
echo "Database: $DATABASE_NAME"
echo "User: $DATABASE_USER"

# Create temporary password file
PGPASS_FILE="/tmp/.pgpass_$$"
trap 'rm -f "$PGPASS_FILE" 2>/dev/null || true' EXIT

echo "=== Fetching database password from Secret Manager ==="
gcloud secrets versions access latest --secret="$PASSWORD_SECRET" --project="$PROJECT_ID" > "$PGPASS_FILE"

if [ ! -s "$PGPASS_FILE" ]; then
    echo "ERROR: Could not retrieve password from Secret Manager"
    rm -f "$PGPASS_FILE"
    exit 1
fi
echo "Database password retrieved successfully"

# Secure the password file
chmod 600 "$PGPASS_FILE"

# Get connection name for Cloud SQL Proxy
echo "=== Getting Cloud SQL connection name ==="
CONNECTION_NAME=$(gcloud sql instances describe "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --format="value(connectionName)")

if [ -z "$CONNECTION_NAME" ]; then
    echo "ERROR: Could not get connection name for instance $INSTANCE_NAME"
    exit 1
fi
echo "Connection name: $CONNECTION_NAME"

# Download and setup Cloud SQL Proxy if not available
PROXY_VERSION=2.8.0
PROXY_BIN=cloud-sql-proxy
PROXY_CHECKSUM=831a5007b6a087c917bf6b46eb7df6289ea37bab7b655c9ed172b8d9e7011e78

if ! command -v "${PROXY_BIN}" > /dev/null; then
    echo "=== Installing Cloud SQL Proxy v${PROXY_VERSION} ==="
    PROXY_URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v${PROXY_VERSION}/${PROXY_BIN}.linux.amd64"

    curl -fsSL "${PROXY_URL}" -o "${PROXY_BIN}"
    echo "${PROXY_CHECKSUM}  ${PROXY_BIN}" | sha256sum -c --quiet - || {
        echo "ERROR: checksum mismatch for ${PROXY_BIN}"
        rm -f "${PROXY_BIN}"
        exit 1
    }

    chmod +x "${PROXY_BIN}"
    mkdir -p "$HOME/bin"
    mv "${PROXY_BIN}" "$HOME/bin/"
    export PATH="$HOME/bin:$PATH"
    echo "Cloud SQL Proxy installed successfully"
else
    echo "Cloud SQL Proxy already available"
fi

# Setup cleanup
PROXY_PID=""
cleanup() {
    if [ -n "$PROXY_PID" ]; then
        echo "Cleaning up Cloud SQL Proxy (PID: $PROXY_PID)..."
        kill "$PROXY_PID" 2>/dev/null || true
        wait "$PROXY_PID" 2>/dev/null || true
    fi
    rm -f "$PGPASS_FILE" 2>/dev/null || true
    # Clean up socket directory
    rm -rf /tmp/cloudsql 2>/dev/null || true
}
trap cleanup EXIT

# Create socket directory (like Cloud Run environment)
mkdir -p /tmp/cloudsql

echo "=== Starting Cloud SQL Proxy with Unix socket ==="
${PROXY_BIN} --unix-socket /tmp/cloudsql "$CONNECTION_NAME" &
PROXY_PID=$!
echo "Cloud SQL Proxy started (PID: $PROXY_PID)"

# Wait for socket to be ready
SOCKET_PATH="/tmp/cloudsql/$CONNECTION_NAME"
echo "Waiting for Unix socket to be ready: $SOCKET_PATH"
for i in $(seq 1 30); do
    if [ -S "$SOCKET_PATH" ]; then
        echo "Unix socket is ready!"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: Unix socket failed to appear within 30 seconds"
        exit 1
    fi
    sleep 1
done

get_password() {
    cat "$PGPASS_FILE"
}

echo "=== Testing database connection via Unix socket ==="

DB_PASSWORD=$(get_password)
export PGPASSWORD="$DB_PASSWORD"

if psql -h "$SOCKET_PATH" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "Database connection via Unix socket successful!"
else
    echo "ERROR: Cannot connect to database via Unix socket"
    unset PGPASSWORD DB_PASSWORD
    exit 1
fi

# Create schema_migrations table if it doesn't exist
echo "=== Ensuring migrations table exists ==="
psql -h "$SOCKET_PATH" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c "
CREATE TABLE IF NOT EXISTS schema_migrations (
    version bigint NOT NULL PRIMARY KEY,
    dirty boolean NOT NULL
);" > /dev/null 2>&1

# Clear password from memory after psql operations
unset PGPASSWORD DB_PASSWORD

echo "=== Running migration: $MIGRATION_COMMAND ==="

run_migration_secure() {
    local password="$(get_password)"

    local database_url="postgres://${DATABASE_USER}:${password}@/${DATABASE_NAME}?host=${SOCKET_PATH}&sslmode=disable"

    migrate -path /migrations -database "$database_url" "$@"

    unset password database_url
}

case $MIGRATION_COMMAND in
    "up")
        echo "Running all pending migrations..."
        run_migration_secure up
        ;;
    "down")
        echo "Rolling back one migration..."
        run_migration_secure down 1
        ;;
    "down-all")
        echo "Rolling back all migrations..."
        run_migration_secure down -all
        ;;
    "version")
        echo "Current migration version:"
        run_migration_secure version
        ;;
    "force")
        if [ -z "$2" ]; then
            echo "ERROR: force command requires a version number"
            echo "Usage: force <version>"
            exit 1
        fi
        echo "Forcing migration to version $2..."
        run_migration_secure force "$2"
        ;;
    "goto")
        if [ -z "$2" ]; then
            echo "ERROR: goto command requires a version number"
            echo "Usage: goto <version>"
            exit 1
        fi
        echo "Migrating to version $2..."
        run_migration_secure goto "$2"
        ;;
    *)
        echo "ERROR: Unknown command: $MIGRATION_COMMAND"
        echo "Available commands: up, down, down-all, version, force <version>, goto <version>"
        exit 1
        ;;
esac

echo "=== Migration completed successfully! ==="
