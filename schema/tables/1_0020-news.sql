CREATE TYPE NEWS_SENTIMENT AS ENUM ('undefined', 'good', 'indifferent', 'bad');
CREATE TYPE NEWS_GENRE AS ENUM ('tech', 'gaming', 'finance');
CREATE TABLE IF NOT EXISTS NEWS (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    headline VARCHAR(255) NOT NULL,
    link_to_source VARCHAR(255) UNIQUE NOT NULL,
    description VARCHAR(255),
    sentiment NEWS_SENTIMENT NOT NULL DEFAULT 'undefined',
    genre NEWS_GENRE NOT NULL
);