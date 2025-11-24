UPDATE PROJECT_REPOSITORIES
SET TITLE = 'Backend',
    DESCRIPTION = 'Backend of the personal portfolio',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-main-back-v2';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'Frontend',
    DESCRIPTION = 'Frontend of the personal portfolio',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-main-front-v2';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'Orchestration',
    DESCRIPTION = 'Orchestration of the personal portfolio',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-orchestration';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'DB Schema',
    DESCRIPTION = 'Database schema of the personal portfolio',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-db-schema';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'Old Frontend',
    DESCRIPTION = 'Old frontend of the personal portfolio',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-main-front';

UPDATE PROJECT_REPOSITORIES
SET TITLE = 'Old Backend',
    DESCRIPTION = 'Old backend of the personal portfolio',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE link_to_git = 'https://github.com/David-Xilo/personal-portfolio-main-back';


COMMIT;

