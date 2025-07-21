
ALTER TABLE PROJECT_GROUPS ADD COLUMN IF NOT EXISTS LINK_TO_PROJECT VARCHAR(255);

UPDATE PROJECT_GROUPS
SET LINK_TO_PROJECT = 'https://safehouse.casa'
WHERE title = 'Safehouse' AND project_type = 'tech';

ALTER TABLE PROJECT_GROUPS ADD CONSTRAINT UNIQUE_LINK_TO_PROJECT UNIQUE (LINK_TO_PROJECT);

CREATE TABLE IF NOT EXISTS PROJECT_REPOSITORIES (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NULL,
    deleted_at TIMESTAMP DEFAULT NULL,
    project_group_id INTEGER NOT NULL,
    title VARCHAR(255) UNIQUE NOT NULL,
    description VARCHAR(255) NOT NULL,
    link_to_git VARCHAR(255) UNIQUE NOT NULL,

    CONSTRAINT fk_projects_group
        FOREIGN KEY (project_group_id)
            REFERENCES PROJECT_GROUPS(id)
            ON DELETE CASCADE
);

INSERT INTO PROJECT_REPOSITORIES (project_group_id, title, description, link_to_git)
SELECT project_group_id, title, description, link_to_git FROM TECH_REPOSITORIES;

INSERT INTO PROJECT_REPOSITORIES (project_group_id, title, description, link_to_git)
SELECT project_group_id, title, description, link_to_git FROM FINANCE_REPOSITORIES;

INSERT INTO PROJECT_REPOSITORIES (project_group_id, title, description, link_to_git)
SELECT project_group_id, title, description, link_to_git FROM GAME_REPOSITORIES
WHERE link_to_git IS NOT NULL;

INSERT INTO PROJECT_REPOSITORIES (project_group_id, title, description, link_to_git)
SELECT
    pg.id,
    'safehouse-orchestration',
    'The Orchestration repo for the website',
    'https://github.com/David-Xilo/safehouse-orchestration'
FROM PROJECT_GROUPS pg
WHERE pg.title = 'Safehouse'
  AND pg.project_type = 'tech'
  AND pg.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM PROJECT_REPOSITORIES
    WHERE title = 'safehouse-orchestration'
);

CREATE INDEX idx_projects_group_id ON PROJECT_REPOSITORIES(project_group_id);

ALTER TABLE GAME_REPOSITORIES DROP CONSTRAINT IF EXISTS fk_game_projects_group;
ALTER TABLE TECH_REPOSITORIES DROP CONSTRAINT IF EXISTS fk_tech_projects_group;
ALTER TABLE FINANCE_REPOSITORIES DROP CONSTRAINT IF EXISTS fk_finance_projects_group;

DROP INDEX IF EXISTS idx_game_projects_group_id;
DROP INDEX IF EXISTS idx_tech_projects_group_id;
DROP INDEX IF EXISTS idx_finance_projects_group_id;

DROP TABLE IF EXISTS GAME_REPOSITORIES;
DROP TABLE IF EXISTS TECH_REPOSITORIES;
DROP TABLE IF EXISTS FINANCE_REPOSITORIES;
