#!/bin/sh
set -e

# This file exists just to run locally

REQUIRED_VARS="POSTGRES_HOST POSTGRES_PORT POSTGRES_USER POSTGRES_DB POSTGRES_PASSWORD"

for VAR in $REQUIRED_VARS; do
  # Use eval to fetch the variable's value via its name
  eval VAL=\$$VAR
  if [ -z "$VAL" ]; then
    echo "Error: Environment variable $VAR is not set." >&2
    exit 1
  fi
done

echo "=== Waiting for PostgreSQL to be ready ==="
until pg_isready -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"; do
  echo "PostgreSQL not ready yet, waiting 2 seconds..."
  sleep 2
done

echo "=== PostgreSQL is ready! ==="

echo "=== Running migration ==="
export PGHOST="${POSTGRES_HOST}"
export PGPORT="${POSTGRES_PORT}"
export PGDATABASE="${POSTGRES_DB}"
export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGSSLMODE="disable"
migrate -path /migrations -database "postgres://${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=disable" "${1:-up}"

echo "=== Migration completed successfully ==="
