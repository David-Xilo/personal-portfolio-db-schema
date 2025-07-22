
UPDATE PROJECT_GROUPS
SET LINK_TO_PROJECT = 'https://davidmoura.net'
WHERE description = 'A basic personal portfolio website' AND project_type = 'tech';

UPDATE PROJECT_GROUPS
SET TITLE = 'Personal Portfolio'
WHERE description = 'A basic personal portfolio website' AND project_type = 'tech';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-main-back'
WHERE description = 'The Backend of the website';

UPDATE PROJECT_REPOSITORIES
SET LINK_TO_GIT = 'https://github.com/David-Xilo/personal-portfolio-main-back'
WHERE description = 'The Backend of the website';


UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-main-front'
WHERE description = 'The Frontend of the website';

UPDATE PROJECT_REPOSITORIES
SET LINK_TO_GIT = 'https://github.com/David-Xilo/personal-portfolio-main-front'
WHERE description = 'The Frontend of the website';


UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-db-schema'
WHERE description = 'The database schema and scripts of the website';

UPDATE PROJECT_REPOSITORIES
SET LINK_TO_GIT = 'https://github.com/David-Xilo/personal-portfolio-db-schema'
WHERE description = 'The database schema and scripts of the website';


UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-orchestration'
WHERE description = 'The Orchestration repo for the website';

UPDATE PROJECT_REPOSITORIES
SET LINK_TO_GIT = 'https://github.com/David-Xilo/personal-portfolio-orchestration'
WHERE description = 'The Orchestration repo for the website';

