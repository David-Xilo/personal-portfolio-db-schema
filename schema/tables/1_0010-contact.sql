CREATE TABLE IF NOT EXISTS CONTACT (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    linkedin VARCHAR(255),
    github VARCHAR(255),
    active bool NOT NULL
);

CREATE UNIQUE INDEX unique_active_contact ON CONTACT (active)
WHERE active = true;
