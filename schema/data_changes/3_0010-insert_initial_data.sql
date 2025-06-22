INSERT INTO CONTACTS (name, email, linkedin, github, credly, active)
SELECT 'David Bugalho de Moura', 'david.dbmoura@gmail.com', 'https://www.linkedin.com/in/davidbmoura/', 'https://github.com/David-Xilo', 'https://www.credly.com/users/david-bugalho-de-moura', true
WHERE NOT EXISTS (
    SELECT 1 FROM CONTACTS
    WHERE email = 'david.dbmoura@gmail.com'
);


INSERT INTO GAMES_PLAYED (title, genre, rating, description)
SELECT 'Skyrim', 'RPG', 5, 'A sprawling, snow-drenched Nordic realm to freely explore, brimming with epic dragon battles, rich lore, unforgettable quests, dynamic combat, and endless mod-friendly adventures.'
WHERE NOT EXISTS (
    SELECT 1 FROM GAMES_PLAYED
    WHERE title = 'Skyrim'
);

INSERT INTO GAMES_PLAYED (title, genre, rating, description)
SELECT 'DnD', 'table top', 5, 'Dungeons & Dragons is a boundless fantasy role-playing game full of imaginative storytelling, camaraderie, problem-solving, and epic quests—empowering creativity, teamwork, and adventure at every roll of the dice.'
WHERE NOT EXISTS (
    SELECT 1 FROM GAMES_PLAYED
    WHERE title = 'DnD'
);

INSERT INTO GAMES_PLAYED (title, genre, rating, description)
SELECT 'Age of Empires II', 'strategy', 4, 'Age of Empires II is a legendary real-time strategy game set in the Middle Ages—build thriving empires across 13 civilizations, master resource economy, epic battles, historic campaigns, and deep multiplayer—timeless classic'
WHERE NOT EXISTS (
    SELECT 1 FROM GAMES_PLAYED
    WHERE title = 'Age of Empires II'
);

INSERT INTO GAMES_PLAYED (title, genre, rating, description)
SELECT 'Final Fantasy 7', 'RPG', 4, 'Final Fantasy VII is a timeless, genre‑defining RPG—rich with unforgettable characters, sweeping eco‑drama, cinematic twists, iconic music, and deep, emotion‑driven storytelling that still enthralls'
WHERE NOT EXISTS (
    SELECT 1 FROM GAMES_PLAYED
    WHERE title = 'Final Fantasy 7'
);

INSERT INTO PROJECT_GROUPS (project_type, title, description)
SELECT 'tech', 'Safehouse', 'A basic personal portfolio website'
WHERE NOT EXISTS (
    SELECT 1 FROM PROJECT_GROUPS
    WHERE title = 'Safehouse' AND project_type = 'tech'
);

INSERT INTO TECH_PROJECTS (project_group_id, title, description, link_to_git)
SELECT
    pg.id,
    'safehouse-main-back',
    'The Backend of the website',
    'https://github.com/David-Xilo/safehouse-main-back'
FROM PROJECT_GROUPS pg
WHERE pg.title = 'Safehouse'
  AND pg.project_type = 'tech'
  AND pg.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM TECH_PROJECTS
    WHERE title = 'safehouse-main-back'
);

INSERT INTO TECH_PROJECTS (project_group_id, title, description, link_to_git)
SELECT
    pg.id,
    'safehouse-main-front',
    'The Frontend of the website',
    'https://github.com/David-Xilo/safehouse-main-front'
FROM PROJECT_GROUPS pg
WHERE pg.title = 'Safehouse'
  AND pg.project_type = 'tech'
  AND pg.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM TECH_PROJECTS
    WHERE title = 'safehouse-main-front'
);

INSERT INTO TECH_PROJECTS (project_group_id, title, description, link_to_git)
SELECT
    pg.id,
    'safehouse-db-schema',
    'The database schema and scripts of the website',
    'https://github.com/David-Xilo/safehouse-db-schema'
FROM PROJECT_GROUPS pg
WHERE pg.title = 'Safehouse'
  AND pg.project_type = 'tech'
  AND pg.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM TECH_PROJECTS
    WHERE title = 'safehouse-db-schema'
);

COMMIT;