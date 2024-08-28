CREATE TYPE GAME_GENRE AS ENUM ('undefined', 'strategy', 'table top');
CREATE TABLE IF NOT EXISTS GAME (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) UNIQUE NOT NULL,
    genre GAME_GENRE NOT NULL DEFAULT 'undefined',
    description VARCHAR(255) NOT NULL,
    link_to_store VARCHAR(255) UNIQUE NOT NULL,
    link_to_git VARCHAR(255)
);
