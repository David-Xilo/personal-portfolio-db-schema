ALTER TABLE PROJECT_GROUPS ADD COLUMN IF NOT EXISTS IMAGE_URL VARCHAR(500);

UPDATE PROJECT_GROUPS
SET IMAGE_URL = 'https://res.cloudinary.com/drngniorr/image/upload/v1764096154/DM-personal-portfolio-cut_y0gr4f.png',
    UPDATED_AT = CURRENT_TIMESTAMP
WHERE TITLE = 'Personal Portfolio' AND project_type = 'tech';

COMMIT;
