#!/bin/sh
set -e

echo "=== Safehouse Migration Runner (Cloud SQL Proxy - Unix Socket) ==="

MIGRATION_COMMAND=${1:-up}
echo "Migration command: $MIGRATION_COMMAND"

validate_environment() {
    local REQUIRED_VARS="PROJECT_ID INSTANCE_NAME DATABASE_NAME DATABASE_USER"
    for VAR in $REQUIRED_VARS; do
        eval VAL=\$"$VAR"
        if [ -z "$VAL" ]; then
            echo "ERROR: Environment variable $VAR is not set."
            echo "Run '$0 --help' for usage information."
            exit 1
        fi
    done

    echo "Project ID: $PROJECT_ID"
    echo "Instance: $INSTANCE_NAME"
    echo "Database: $DATABASE_NAME"
    echo "User: $DATABASE_USER"

    if [ "$USE_IAM_AUTH" = "true" ]; then
        echo "Authentication: IAM (no passwords)"
        if [ -n "$DB_SERVICE_ACCOUNT" ]; then
            echo "Service Account Impersonation: $DB_SERVICE_ACCOUNT"
        else
            echo "Service Account: Using current credentials"
        fi
    else
        if [ -z "$DB_PASSWORD" ] && [ -z "$PASSWORD_SECRET" ]; then
            echo "ERROR: Either DB_PASSWORD or PASSWORD_SECRET must be set."
            echo "Run '$0 --help' for usage information."
            exit 1
        fi
        if [ -n "$DB_PASSWORD" ]; then
            echo "Authentication: Direct password"
        else
            echo "Authentication: Secret Manager ($PASSWORD_SECRET)"
        fi
    fi
}

install_cloud_sql_proxy() {
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
}

get_iam_token() {
    if [ -n "$GOOGLE_ACCESS_TOKEN" ]; then
        echo "Using provided Google access token"
        echo "$GOOGLE_ACCESS_TOKEN"
    elif [ -n "$DB_SERVICE_ACCOUNT" ]; then
        echo "Getting IAM token with service account impersonation: $DB_SERVICE_ACCOUNT"
        gcloud auth print-access-token --impersonate-service-account="$DB_SERVICE_ACCOUNT"
    else
        echo "Getting IAM token with current credentials"
        gcloud auth print-access-token
    fi
}

setup_iam_database_connection() {
    echo "=== Setting up IAM database connection ==="

    if [ -n "$GOOGLE_ACCESS_TOKEN" ]; then
        echo "Authenticating gcloud with provided token"
        echo "$GOOGLE_ACCESS_TOKEN" | gcloud auth activate-service-account --access-token-file=-
    fi

    CONNECTION_NAME=$(gcloud sql instances describe "$INSTANCE_NAME" \
        --project="$PROJECT_ID" \
        --format="value(connectionName)")

    if [ -z "$CONNECTION_NAME" ]; then
        echo "ERROR: Could not get connection name for instance $INSTANCE_NAME"
        exit 1
    fi
    echo "Connection name: $CONNECTION_NAME"

    install_cloud_sql_proxy

    mkdir -p /tmp/cloudsql
    echo "=== Starting Cloud SQL Proxy with Unix socket ==="
    ${PROXY_BIN:-cloud-sql-proxy} --unix-socket /tmp/cloudsql "$CONNECTION_NAME" &
    PROXY_PID=$!
    echo "Cloud SQL Proxy started (PID: $PROXY_PID)"

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

    echo "=== Getting IAM token for database authentication ==="
    IAM_TOKEN=$(get_iam_token)

    if [ -z "$IAM_TOKEN" ]; then
        echo "ERROR: Could not get IAM access token"
        exit 1
    fi

    export PGPASSWORD="$IAM_TOKEN"
    if psql -h "$SOCKET_PATH" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
        echo "IAM database connection successful!"
    else
        echo "ERROR: Cannot connect to database with IAM authentication"
        echo "Check that:"
        echo "  1. Database user '$DATABASE_USER' exists as IAM user"
        echo "  2. Service account has cloudsql.instanceUser permission"
        echo "  3. IAM authentication is enabled on the database"
        unset PGPASSWORD
        exit 1
    fi
    unset PGPASSWORD

    # Create schema_migrations table if it doesn't exist
    echo "=== Ensuring migrations table exists ==="
    IAM_TOKEN_FRESH=$(get_iam_token)
    export PGPASSWORD="$IAM_TOKEN_FRESH"
    psql -h "$SOCKET_PATH" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c "
    CREATE TABLE IF NOT EXISTS schema_migrations (
        version bigint NOT NULL PRIMARY KEY,
        dirty boolean NOT NULL
    );" > /dev/null 2>&1
    unset PGPASSWORD IAM_TOKEN_FRESH
}

setup_database_connection() {
    # Create temporary password file
    PGPASS_FILE="/tmp/.pgpass_$$"
    trap 'cleanup' EXIT

    # Get password - either from direct env var or Secret Manager
    if [ -n "$DB_PASSWORD" ]; then
        echo "=== Using direct password from environment variable ==="
        echo "$DB_PASSWORD" > "$PGPASS_FILE"
    else
        echo "=== Fetching database password from Secret Manager ==="
        gcloud secrets versions access latest --secret="$PASSWORD_SECRET" --project="$PROJECT_ID" > "$PGPASS_FILE"
    fi

    if [ ! -s "$PGPASS_FILE" ]; then
        echo "ERROR: Could not retrieve password"
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

    # Install Cloud SQL Proxy
    install_cloud_sql_proxy

    mkdir -p /tmp/cloudsql

    echo "=== Starting Cloud SQL Proxy with Unix socket ==="
    ${PROXY_BIN:-cloud-sql-proxy} --unix-socket /tmp/cloudsql "$CONNECTION_NAME" &
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

    echo "=== Testing database connection via Unix socket ==="

    DB_PASSWORD_VALUE="$(cat "$PGPASS_FILE")"
    export PGPASSWORD="$DB_PASSWORD_VALUE"

    if psql -h "$SOCKET_PATH" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
        echo "Database connection via Unix socket successful!"
    else
        echo "ERROR: Cannot connect to database via Unix socket"
        unset PGPASSWORD DB_PASSWORD_VALUE
        exit 1
    fi

    # Create schema_migrations table if it doesn't exist
    echo "=== Ensuring migrations table exists ==="
    psql -h "$SOCKET_PATH" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c "
    CREATE TABLE IF NOT EXISTS schema_migrations (
        version bigint NOT NULL PRIMARY KEY,
        dirty boolean NOT NULL
    );" > /dev/null 2>&1

    unset PGPASSWORD DB_PASSWORD_VALUE
}

cleanup() {
    if [ -n "$PROXY_PID" ]; then
        echo "Cleaning up Cloud SQL Proxy (PID: $PROXY_PID)"
        kill "$PROXY_PID" 2>/dev/null || true
        wait "$PROXY_PID" 2>/dev/null || true
    fi
    rm -f "$PGPASS_FILE" 2>/dev/null || true
    rm -rf /tmp/cloudsql 2>/dev/null || true
}

run_migration_iam() {
    local iam_token="$(get_iam_token)"
    local database_url="postgres://${DATABASE_USER}:${iam_token}@/${DATABASE_NAME}?host=${SOCKET_PATH}&sslmode=disable"

    migrate -path /migrations -database "$database_url" "$@"

    unset iam_token database_url
}

run_migration_secure() {
    local password="$(cat "$PGPASS_FILE")"
    local database_url="postgres://${DATABASE_USER}:${password}@/${DATABASE_NAME}?host=${SOCKET_PATH}&sslmode=disable"

    migrate -path /migrations -database "$database_url" "$@"

    unset password database_url
}

run_migration() {
    if [ "$USE_IAM_AUTH" = "true" ]; then
        run_migration_iam "$@"
    else
        run_migration_secure "$@"
    fi
}

setup_connection() {
    if [ "$USE_IAM_AUTH" = "true" ]; then
        setup_iam_database_connection
    else
        setup_database_connection
    fi
}

case $MIGRATION_COMMAND in
    "--help"|"-h"|"help")
        echo ""
        echo "Safehouse Database Migration Runner"
        echo "==================================="
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  up        Run all pending migrations (default)"
        echo "  down      Rollback one migration"
        echo "  down-all  Rollback all migrations"
        echo "  version   Show current migration version"
        echo "  force N   Force database to version N"
        echo "  goto N    Migrate to specific version N"
        echo "  help      Show this help message"
        echo "  test-tools Test if required tools are available"
        echo ""
        echo "Required Environment Variables (for migration commands):"
        echo "  PROJECT_ID      - Google Cloud project ID"
        echo "  INSTANCE_NAME   - Cloud SQL instance name"
        echo "  DATABASE_NAME   - Database name"
        echo "  DATABASE_USER   - Database user (short name for IAM auth)"
        echo ""
        echo "Authentication Options:"
        echo "  USE_IAM_AUTH=true     - Use IAM authentication (recommended)"
        echo "  DB_SERVICE_ACCOUNT    - Service account email for impersonation (optional)"
        echo "  PASSWORD_SECRET       - Secret Manager secret name for password"
        echo "  DB_PASSWORD          - Database password directly"
        echo ""
        echo "Examples:"
        echo ""
        echo "  # IAM authentication with current credentials"
        echo "  docker run --rm \\"
        echo "    -e PROJECT_ID=my-project \\"
        echo "    -e USE_IAM_AUTH=true \\"
        echo "    -e DATABASE_USER=short-sa-name \\"
        echo "    migration-image up"
        echo ""
        echo "  # IAM authentication with service account impersonation"
        echo "  docker run --rm \\"
        echo "    -e PROJECT_ID=my-project \\"
        echo "    -e USE_IAM_AUTH=true \\"
        echo "    -e DATABASE_USER=short-sa-name \\"
        echo "    -e DB_SERVICE_ACCOUNT=db-sa@project.iam.gserviceaccount.com \\"
        echo "    migration-image up"
        echo ""
        echo "  # Password-based authentication with Secret Manager"
        echo "  docker run --rm \\"
        echo "    -e PROJECT_ID=my-project \\"
        echo "    -e DATABASE_USER=db_user \\"
        echo "    -e PASSWORD_SECRET=my-secret \\"
        echo "    migration-image up"
        echo ""
        echo "  # Password-based authentication with direct password"
        echo "  docker run --rm \\"
        echo "    -e PROJECT_ID=my-project \\"
        echo "    -e DATABASE_USER=db_user \\"
        echo "    -e DB_PASSWORD=mypassword \\"
        echo "    migration-image up"
        echo ""
        echo "Notes:"
        echo "  - For IAM auth, DATABASE_USER should be the short service account name"
        echo "  - Service account impersonation requires proper IAM permissions"
        echo "  - gcloud credentials must be available in the container"
        exit 0
        ;;
    "test-tools")
        echo "Testing required tools"
        echo "Checking migrate tool:"
        if which migrate >/dev/null 2>&1; then
            migrate -version
        else
            echo "ERROR: migrate tool not found"
            exit 1
        fi
        echo "Checking psql tool:"
        if which psql >/dev/null 2>&1; then
            psql --version
        else
            echo "ERROR: psql tool not found"
            exit 1
        fi
        echo "Checking gcloud tool:"
        if which gcloud >/dev/null 2>&1; then
            gcloud version --format='value(Google Cloud SDK)' 2>/dev/null || echo "gcloud available"
        else
            echo "ERROR: gcloud tool not found"
            exit 1
        fi
        echo "Testing gcloud authentication:"
        if gcloud auth list --filter=status:ACTIVE --format='value(account)' | head -1 > /dev/null; then
            ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format='value(account)' | head -1)
            echo "Active gcloud account: $ACTIVE_ACCOUNT"

            # Test access token generation
            if [ "$USE_IAM_AUTH" = "true" ]; then
                echo "Testing IAM token generation:"
                if [ -n "$DB_SERVICE_ACCOUNT" ]; then
                    echo "Testing service account impersonation for: $DB_SERVICE_ACCOUNT"
                    if gcloud auth print-access-token --impersonate-service-account="$DB_SERVICE_ACCOUNT" > /dev/null 2>&1; then
                        echo "✓ Service account impersonation successful"
                    else
                        echo "✗ Service account impersonation failed"
                        echo "Check that current account can impersonate $DB_SERVICE_ACCOUNT"
                        exit 1
                    fi
                else
                    echo "Testing current account token generation:"
                    if gcloud auth print-access-token > /dev/null 2>&1; then
                        echo "✓ Access token generation successful"
                    else
                        echo "✗ Access token generation failed"
                        exit 1
                    fi
                fi
            fi
        else
            echo "ERROR: No active gcloud authentication found"
            echo "Run 'gcloud auth login' or ensure service account credentials are available"
            exit 1
        fi
        echo "All required tools are available and properly configured!"
        exit 0
        ;;
    "up")
        validate_environment
        setup_connection
        echo "=== Running migration: up ==="
        echo "Running all pending migrations"
        run_migration up
        echo "=== Migration completed successfully! ==="
        ;;
    "down")
        validate_environment
        setup_connection
        echo "=== Running migration: down ==="
        echo "Rolling back one migration"
        run_migration down 1
        echo "=== Migration completed successfully! ==="
        ;;
    "down-all")
        validate_environment
        setup_connection
        echo "=== Running migration: down-all ==="
        echo "Rolling back all migrations"
        run_migration down -all
        echo "=== Migration completed successfully! ==="
        ;;
    "version")
        validate_environment
        setup_connection
        echo "=== Running migration: version ==="
        echo "Current migration version:"
        run_migration version
        echo "=== Migration completed successfully! ==="
        ;;
    "force")
        if [ -z "$2" ]; then
            echo "ERROR: force command requires a version number"
            echo "Usage: $0 force <version>"
            exit 1
        fi
        validate_environment
        setup_connection
        echo "=== Running migration: force $2 ==="
        echo "Forcing migration to version $2"
        run_migration force "$2"
        echo "=== Migration completed successfully! ==="
        ;;
    "goto")
        if [ -z "$2" ]; then
            echo "ERROR: goto command requires a version number"
            echo "Usage: $0 goto <version>"
            exit 1
        fi
        validate_environment
        setup_connection
        echo "=== Running migration: goto $2 ==="
        echo "Migrating to version $2"
        run_migration goto "$2"
        echo "=== Migration completed successfully! ==="
        ;;
    *)
        echo "ERROR: Unknown command: $MIGRATION_COMMAND"
        echo ""
        echo "Available commands:"
        echo "  up, down, down-all, version, force <version>, goto <version>"
        echo "  help, test-tools"
        echo ""
        echo "Run '$0 --help' for detailed usage information."
        exit 1
        ;;
esac
