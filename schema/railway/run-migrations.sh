#!/bin/sh

set -e

# ADD this section:
echo "🐳 Migration container starting..."
echo "Arguments received: $*"
echo "Working directory: $(pwd)"
echo "Migration files available:"
ls -la /migrations/ || echo "No migrations directory found"

# Wait a moment for Railway to set up environment variables
sleep 2

# Then your existing code continues...
TIMEOUT=${MIGRATION_TIMEOUT:-30}
VERBOSE=${MIGRATION_VERBOSE:-false}
DRY_RUN=${MIGRATION_DRY_RUN:-false}

if [ -z "$DATABASE_URL" ]; then
    echo "ERROR: DATABASE_URL environment variable not set"
    exit 1
fi

echo "🚀 Starting database migrations..."
echo "Database URL: ${DATABASE_URL%@*}@***" # Hide password in logs
echo "Migration command: $*"
echo "Environment: ${RAILWAY_ENVIRONMENT:-unknown}"

if [ "$VERBOSE" = "true" ]; then
    echo "🔧 Configuration:"
    echo "   Timeout: ${TIMEOUT}s"
    echo "   Dry run: $DRY_RUN"
    echo "   Service: ${RAILWAY_SERVICE_NAME:-unknown}"
fi

echo "⏳ Waiting for database connection..."
counter=0
until pg_isready -d "$DATABASE_URL" > /dev/null 2>&1; do
    counter=$((counter + 1))
    if [ $counter -gt $TIMEOUT ]; then
        echo "❌ Database connection timeout after ${TIMEOUT} seconds"
        exit 1
    fi
    if [ "$VERBOSE" = "true" ]; then
        echo "   Attempting connection... ($counter/$TIMEOUT)"
    fi
    sleep 1
done

echo "✅ Database connection established"

echo "📋 Current migration version:"
migrate -path /migrations -database "$DATABASE_URL" version || echo "No migrations applied yet"

if [ "$DRY_RUN" = "true" ]; then
    echo "🧪 Dry run mode - validating migrations only"
    migrate -path /migrations -database "$DATABASE_URL" version
    echo "✅ Migration validation completed (dry run)"
    exit 0
fi

if [ $# -eq 0 ]; then
    COMMAND="up"
    set -- "up"
else
    COMMAND="$1"
fi
echo "🔄 Running migration: $COMMAND"

if migrate -path /migrations -database "$DATABASE_URL" "$@"; then
    echo "✅ Migrations completed successfully"

    # Show final migration version
    echo "📋 Final migration version:"
    migrate -path /migrations -database "$DATABASE_URL" version

    exit 0
else
    echo "❌ Migration failed"
    exit 1
fi

echo "✅ Migrations completed successfully"

# Show final migration version
echo "📋 Final migration version:"
migrate -path /migrations -database "$DATABASE_URL" version

# ADD these lines:
echo "🐳 Migration container finished - exiting"
sleep 1  # Give logs time to flush
exit 0
echo "🐳 Forcing kill"
sleep 2
kill $$

