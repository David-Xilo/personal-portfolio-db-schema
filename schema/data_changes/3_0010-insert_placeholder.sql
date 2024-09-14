INSERT INTO CONTACTS (name, email, linkedin, github, active)
VALUES ('John Doe', 'johndoe@example.com', 'https://www.linkedin.com/in/johndoe', 'https://github.com/johndoe', true);

insert into NEWS (headline, link_to_source, description, sentiment, genre)
values ('tech headline', 'https://www.linkedin.com/in/johndoe', 'tech news description', 'undefined', 'tech');

insert into NEWS (headline, link_to_source, description, sentiment, genre)
values ('tech headline', 'https://www.linkedin.com/in/john', 'tech news description', 'indifferent', 'tech');

insert into NEWS (headline, link_to_source, description, sentiment, genre)
values ('gaming headline', 'https://www.linkedin.com/in/doe', 'gaming news description', 'good', 'gaming');

insert into NEWS (headline, link_to_source, description, sentiment, genre)
values ('finance headline', 'https://www.linkedin.com/in/john-doe', 'finance news description', 'bad', 'finance');


insert into TOPIC_OF_THE_SEASONS (topic, genre, topic_timestamp, type, custom_start, custom_end)
values ('tech topic', 'tech', CURRENT_TIMESTAMP, '1w', null, null);

insert into TOPIC_OF_THE_SEASONS (topic, genre, topic_timestamp, type, custom_start, custom_end)
values ('gaming topic', 'gaming', CURRENT_TIMESTAMP, '1m', null, null);

insert into TOPIC_OF_THE_SEASONS (topic, genre, topic_timestamp, type, custom_start, custom_end)
values ('finance topic', 'finance', CURRENT_TIMESTAMP, 'custom', now() - INTERVAL '45 DAYS', now() + INTERVAL '10 DAYS');


insert into NEWS_TOPIC_OF_THE_SEASONS (news_id, topic_of_the_season_id)
values ((select id from news where genre = 'tech' and sentiment = 'undefined'), (select id from topic_of_the_seasons where genre = 'tech'));

insert into NEWS_TOPIC_OF_THE_SEASONS (news_id, topic_of_the_season_id)
values ((select id from news where genre = 'tech' and sentiment = 'indifferent'), (select id from topic_of_the_seasons where genre = 'tech'));

insert into NEWS_TOPIC_OF_THE_SEASONS (news_id, topic_of_the_season_id)
values ((select id from news where genre = 'gaming'), (select id from topic_of_the_seasons where genre = 'tech'));

insert into NEWS_TOPIC_OF_THE_SEASONS (news_id, topic_of_the_season_id)
values ((select id from news where genre = 'finance'), (select id from topic_of_the_seasons where genre = 'tech'));


insert into GAMES (title, genre, rating, description, link_to_store, link_to_git)
values ('game title', 'strategy', null, 'game description', 'https://github.com/game', 'https://github.com/johndoe');

insert into GAMES (title, genre, rating, description, link_to_store, link_to_git)
values ('game with rating title', 'table top', 3, 'game with rating description', 'https://github.com/othergame', null);


insert into TECH_PROJECTS (title, description, link_to_git)
values ('tech project title', 'project description', 'https://github.com/johndoe');

