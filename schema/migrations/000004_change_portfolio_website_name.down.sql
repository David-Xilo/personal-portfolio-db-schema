
UPDATE PROJECT_REPOSITORIES
SET TITLE = 'safehouse-orchestration',
    LINK_TO_GIT = 'https://github.com/David-Xilo/safehouse-orchestration'
WHERE description = 'The Orchestration repo for the website';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'safehouse-db-schema',
    LINK_TO_GIT = 'https://github.com/David-Xilo/safehouse-db-schema'
WHERE description = 'The database schema and scripts of the website';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'safehouse-main-front',
    LINK_TO_GIT = 'https://github.com/David-Xilo/safehouse-main-front'
WHERE description = 'The Frontend of the website';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'safehouse-main-back',
    LINK_TO_GIT = 'https://github.com/David-Xilo/safehouse-main-back'
WHERE description = 'The Backend of the website';

UPDATE PROJECT_GROUPS
SET TITLE = 'Safehouse'
WHERE description = 'A basic personal portfolio website' AND project_type = 'tech';

UPDATE PROJECT_GROUPS
SET LINK_TO_PROJECT = 'https://safehouse.casa'
WHERE description = 'A basic personal portfolio website' AND project_type = 'tech';
