DELETE FROM TECH_REPOSITORIES WHERE title IN ('safehouse-main-back', 'safehouse-main-front', 'safehouse-db-schema');
DELETE FROM PROJECT_GROUPS WHERE title = 'Safehouse' AND project_type = 'tech';
DELETE FROM GAMES_PLAYED WHERE title IN ('Skyrim', 'DnD', 'Age of Empires II', 'Final Fantasy 7');
DELETE FROM CONTACTS WHERE email = 'david.dbmoura@gmail.com';
