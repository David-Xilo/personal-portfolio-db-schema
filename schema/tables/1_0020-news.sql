CREATE TYPE NEWS_SENTIMENTS AS ENUM ('undefined', 'good', 'indifferent', 'bad');
CREATE TYPE NEWS_GENRES AS ENUM ('tech', 'gaming', 'finance');
CREATE TABLE IF NOT EXISTS NEWS (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NULL,
    deleted_at TIMESTAMP DEFAULT NULL,
    headline VARCHAR(255) NOT NULL,
    link_to_source VARCHAR(255) UNIQUE NOT NULL,
    description VARCHAR(255),
    sentiment NEWS_SENTIMENTS NOT NULL DEFAULT 'undefined',
    genre NEWS_GENRES NOT NULL
);