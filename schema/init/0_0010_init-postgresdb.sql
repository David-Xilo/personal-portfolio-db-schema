-- CREATE USER "safehouse-main-user" WITH PASSWORD 'mypassword';
-- CREATE DATABASE "safehouse-main-db" OWNER "safehouse-main-user";
DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT FROM pg_catalog.pg_roles
            WHERE rolname = 'safehouse-main-user') THEN
            CREATE ROLE "safehouse-main-user" WITH LOGIN PASSWORD 'mypassword';
        END IF;
    END
$$;

DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT FROM pg_database
            WHERE datname = 'safehouse-main-db') THEN
            CREATE DATABASE "safehouse-main-db" OWNER "safehouse-main-user";
        END IF;
    END
$$;
