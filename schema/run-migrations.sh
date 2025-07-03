#!/bin/sh
set -e

#echo "=== Migration Debug Info ==="
#echo "POSTGRES_HOST: '${POSTGRES_HOST}'"
#echo "POSTGRES_PORT: '${POSTGRES_PORT}'"
#echo "POSTGRES_USER: '${POSTGRES_USER}'"
#echo "POSTGRES_DB: '${POSTGRES_DB}'"

echo "=== Waiting for PostgreSQL to be ready ==="
until pg_isready -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d ${POSTGRES_DB}; do
  echo "PostgreSQL not ready yet, waiting 2 seconds..."
  sleep 2
done

echo "=== PostgreSQL is ready! ==="

DATABASE_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=disable"

echo "=== Database URL ==="
echo ${DATABASE_URL}

echo "=== Running migration ==="
migrate -path /migrations -database ${DATABASE_URL} ${1:-up}

echo "=== Migration completed successfully ==="