#!/bin/sh
set -e

# This file exists just to run locally

echo "=== Waiting for PostgreSQL to be ready ==="
until pg_isready -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"; do
  echo "PostgreSQL not ready yet, waiting 2 seconds..."
  sleep 2
done

echo "=== PostgreSQL is ready! ==="

DATABASE_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=disable"

echo "=== Running migration ==="
migrate -path /migrations -database "${DATABASE_URL}" "${1:-up}"

echo "=== Migration completed successfully ==="
