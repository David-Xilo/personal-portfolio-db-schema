-- CREATE USER "dev_user" WITH PASSWORD 'mypassword';
-- CREATE DATABASE "dev_db" OWNER "dev_user";
DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT FROM pg_catalog.pg_roles
            WHERE rolname = 'dev_user') THEN
            CREATE ROLE "dev_user" WITH LOGIN PASSWORD 'mypassword';
        ELSE
            RAISE NOTICE 'Role "dev_user" already exists, skipping creation.';
        END IF;
    END
$$;

DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT FROM pg_database
            WHERE datname = 'dev_db') THEN
            CREATE DATABASE "dev_db" OWNER "dev_user";
        ELSE
            RAISE NOTICE 'Database "dev_db" already exists, skipping creation.';
        END IF;
    END
$$;
