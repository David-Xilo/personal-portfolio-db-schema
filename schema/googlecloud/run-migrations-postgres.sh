#!/bin/sh
# run-migrations-postgres.sh
DATABASE_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}?sslmode=disable"
migrate -path /migrations -database "$DATABASE_URL" "${1:-up}"

