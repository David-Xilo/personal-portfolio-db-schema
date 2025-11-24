UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-main-back-v2',
    DESCRIPTION = 'Version 2 of Backend',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-main-back-v2';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-main-front-v2',
    DESCRIPTION = 'Version 2 of Frontend',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-main-front-v2';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-orchestration',
    DESCRIPTION = 'The Orchestration repo for the website',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-orchestration';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-db-schema',
    DESCRIPTION = 'The database schema and scripts of the website',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-db-schema';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-main-front',
    DESCRIPTION = 'The Frontend of the website',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-main-front';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'personal-portfolio-main-back',
    DESCRIPTION = 'The Backend of the website',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-main-back';

COMMIT;
