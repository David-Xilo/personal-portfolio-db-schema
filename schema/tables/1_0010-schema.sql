CREATE TABLE IF NOT EXISTS CONTACTS (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NULL,
    deleted_at TIMESTAMP DEFAULT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    linkedin VARCHAR(255),
    github VARCHAR(255),
    credly VARCHAR(255),
    active bool NOT NULL
);

CREATE UNIQUE INDEX unique_active_contact ON CONTACTS (active)
    WHERE active = true;

CREATE TYPE PROJECT_TYPE AS ENUM ('undefined', 'tech', 'game', 'finance');
CREATE TABLE IF NOT EXISTS PROJECT_GROUPS (
     id SERIAL PRIMARY KEY,
     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT NULL,
     deleted_at TIMESTAMP DEFAULT NULL,
     title VARCHAR(255) UNIQUE NOT NULL,
     description VARCHAR(255) NOT NULL,
    project_type PROJECT_TYPE NOT NULL DEFAULT 'undefined'
);

CREATE TYPE GAME_GENRES AS ENUM ('undefined', 'strategy', 'table top', 'RPG');


CREATE TABLE IF NOT EXISTS GAMES_PLAYED (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NULL,
    deleted_at TIMESTAMP DEFAULT NULL,
    title VARCHAR(255) UNIQUE NOT NULL,
    genre GAME_GENRES NOT NULL DEFAULT 'undefined',
    rating INT DEFAULT NULL,
    description VARCHAR(255) NOT NULL
);


CREATE TABLE IF NOT EXISTS GAME_REPOSITORIES (
     id SERIAL PRIMARY KEY,
     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT NULL,
     deleted_at TIMESTAMP DEFAULT NULL,
     project_group_id INTEGER NOT NULL,
     title VARCHAR(255) UNIQUE NOT NULL,
     genre GAME_GENRES NOT NULL DEFAULT 'undefined',
     rating INT DEFAULT NULL,
     description VARCHAR(255) NOT NULL,
     link_to_store VARCHAR(255) UNIQUE NOT NULL,
     link_to_git VARCHAR(255) DEFAULT NULL,

     CONSTRAINT fk_game_projects_group
         FOREIGN KEY (project_group_id)
             REFERENCES PROJECT_GROUPS(id)
             ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS TECH_REPOSITORIES (
     id SERIAL PRIMARY KEY,
     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT NULL,
     deleted_at TIMESTAMP DEFAULT NULL,
     project_group_id INTEGER NOT NULL,
     title VARCHAR(255) UNIQUE NOT NULL,
     description VARCHAR(255) NOT NULL,
     link_to_git VARCHAR(255) UNIQUE NOT NULL,

     CONSTRAINT fk_tech_projects_group
         FOREIGN KEY (project_group_id)
             REFERENCES PROJECT_GROUPS(id)
             ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS FINANCE_REPOSITORIES (
     id SERIAL PRIMARY KEY,
     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT NULL,
     deleted_at TIMESTAMP DEFAULT NULL,
     project_group_id INTEGER NOT NULL,
     title VARCHAR(255) UNIQUE NOT NULL,
     description VARCHAR(255) NOT NULL,
     link_to_git VARCHAR(255) UNIQUE NOT NULL,

     CONSTRAINT fk_finance_projects_group
         FOREIGN KEY (project_group_id)
             REFERENCES PROJECT_GROUPS(id)
             ON DELETE CASCADE
);



CREATE INDEX idx_game_projects_group_id ON GAME_REPOSITORIES(project_group_id);
CREATE INDEX idx_tech_projects_group_id ON TECH_REPOSITORIES(project_group_id);
CREATE INDEX idx_finance_projects_group_id ON FINANCE_REPOSITORIES(project_group_id);

