-- Remove the unique constraint first
ALTER TABLE PROJECT_GROUPS DROP CONSTRAINT IF EXISTS UNIQUE_LINK_TO_PROJECT;

-- Recreate the original repository tables with their original schemas
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

INSERT INTO TECH_REPOSITORIES (project_group_id, title, description, link_to_git, created_at, updated_at, deleted_at)
SELECT pr.project_group_id, pr.title, pr.description, pr.link_to_git, pr.created_at, pr.updated_at, pr.deleted_at
FROM PROJECT_REPOSITORIES pr
         JOIN PROJECT_GROUPS pg ON pr.project_group_id = pg.id
WHERE pg.project_type = 'tech';

INSERT INTO FINANCE_REPOSITORIES (project_group_id, title, description, link_to_git, created_at, updated_at, deleted_at)
SELECT pr.project_group_id, pr.title, pr.description, pr.link_to_git, pr.created_at, pr.updated_at, pr.deleted_at
FROM PROJECT_REPOSITORIES pr
         JOIN PROJECT_GROUPS pg ON pr.project_group_id = pg.id
WHERE pg.project_type = 'finance';

INSERT INTO GAME_REPOSITORIES (project_group_id, title, description, link_to_git, genre, rating, link_to_store, created_at, updated_at, deleted_at)
SELECT pr.project_group_id, pr.title, pr.description, pr.link_to_git,
       'undefined', -- Default genre
       NULL, -- Default rating
       '' || LOWER(REPLACE(pr.title, ' ', '-')),
       pr.created_at, pr.updated_at, pr.deleted_at
FROM PROJECT_REPOSITORIES pr
         JOIN PROJECT_GROUPS pg ON pr.project_group_id = pg.id
WHERE pg.project_type = 'game';

CREATE INDEX idx_game_projects_group_id ON GAME_REPOSITORIES(project_group_id);
CREATE INDEX idx_tech_projects_group_id ON TECH_REPOSITORIES(project_group_id);
CREATE INDEX idx_finance_projects_group_id ON FINANCE_REPOSITORIES(project_group_id);

DROP INDEX IF EXISTS idx_projects_group_id;
DROP TABLE IF EXISTS PROJECT_REPOSITORIES;

ALTER TABLE PROJECT_GROUPS DROP COLUMN IF EXISTS LINK_TO_PROJECT;
