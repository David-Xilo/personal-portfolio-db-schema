#!/bin/sh
set -e

REQUIRED_VARS="DATABASE_URL POSTGRES_HOST POSTGRES_PORT POSTGRES_USER POSTGRES_DB"

for VAR in $REQUIRED_VARS; do
  eval VAL=\$"$VAR"
  if [ -z "$VAL" ]; then
    echo "Error: Environment variable $VAR is not set." >&2
    exit 1
  fi
done

echo "=== Waiting for PostgreSQL to be ready ==="
until psql "${DATABASE_URL}" -c '\q' > /dev/null 2>&1; do
  echo "PostgreSQL not ready yet, waiting 2 seconds..."
  sleep 2
done

echo "=== PostgreSQL is ready! ==="

echo "=== Running migration ==="
migrate -path ../migrations -database "${DATABASE_URL}" "${1:-up}"

echo "=== Migration completed successfully ==="
