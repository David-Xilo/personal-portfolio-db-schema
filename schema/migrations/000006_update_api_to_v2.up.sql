ALTER TABLE PROJECT_GROUPS ADD COLUMN IF NOT EXISTS SHOW_PRIORITY INTEGER;
ALTER TABLE PROJECT_REPOSITORIES ADD COLUMN IF NOT EXISTS SHOW_PRIORITY INTEGER;

UPDATE PROJECT_GROUPS
SET TITLE = 'Personal Portfolio',
    SHOW_PRIORITY = 10,
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE description = 'A basic personal portfolio website' AND project_type = 'tech';

INSERT INTO PROJECT_REPOSITORIES (project_group_id, title, description, link_to_git, show_priority)
SELECT
    pg.id,
    'personal-portfolio-main-back-v2',
    'Version 2 of Backend',
    'https://github.com/David-Xilo/personal-portfolio-main-back-v2',
    100
FROM PROJECT_GROUPS pg
WHERE pg.description = 'A basic personal portfolio website'
  AND pg.project_type = 'tech'
  AND pg.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM PROJECT_REPOSITORIES
    WHERE title = 'personal-portfolio-main-back-v2'
);

INSERT INTO PROJECT_REPOSITORIES (project_group_id, title, description, link_to_git, show_priority)
SELECT
    pg.id,
    'personal-portfolio-main-front-v2',
    'Version 2 of Frontend',
    'https://github.com/David-Xilo/personal-portfolio-main-front-v2',
    100
FROM PROJECT_GROUPS pg
WHERE pg.description = 'A basic personal portfolio website'
  AND pg.project_type = 'tech'
  AND pg.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM PROJECT_REPOSITORIES
    WHERE title = 'personal-portfolio-main-front-v2'
);

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-orchestration',
    LINK_TO_GIT = 'https://github.com/David-Xilo/personal-portfolio-orchestration',
    SHOW_PRIORITY = 70,
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE description = 'The Orchestration repo for the website';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-db-schema',
    LINK_TO_GIT = 'https://github.com/David-Xilo/personal-portfolio-db-schema',
    SHOW_PRIORITY = 50,
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE description = 'The database schema and scripts of the website';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-main-front',
    LINK_TO_GIT = 'https://github.com/David-Xilo/personal-portfolio-main-front',
    SHOW_PRIORITY = 10,
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE description = 'The Frontend of the website';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-main-back',
    LINK_TO_GIT = 'https://github.com/David-Xilo/personal-portfolio-main-back',
    SHOW_PRIORITY = 20,
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE description = 'The Backend of the website';

UPDATE CONTACTS
    SET email = '',
        UPDATED_AT = CURRENT_TIMESTAMP
WHERE name = 'David Bugalho de Moura';


COMMIT;

