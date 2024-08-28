-- Foreign key constraints for Posts
ALTER TABLE TOPIC_OF_THE_SEASON
ADD CONSTRAINT fk_topic_of_the_season FOREIGN KEY (news_id) REFERENCES NEWS(id)
