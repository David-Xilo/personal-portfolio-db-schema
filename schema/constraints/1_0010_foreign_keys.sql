-- Foreign key constraints for Posts
ALTER TABLE Posts
ADD CONSTRAINT fk_posts_user_id FOREIGN KEY (user_id) REFERENCES Users(id),
ADD CONSTRAINT fk_posts_category_id FOREIGN KEY (category_id) REFERENCES Categories(id);

-- Foreign key constraints for Comments
ALTER TABLE Comments
ADD CONSTRAINT fk_comments_post_id FOREIGN KEY (post_id) REFERENCES Posts(id),
ADD CONSTRAINT fk_comments_user_id FOREIGN KEY (user_id) REFERENCES Users(id);

-- Foreign key constraints for Post_Tags
ALTER TABLE Post_Tags
ADD CONSTRAINT fk_post_tags_post_id FOREIGN KEY (post_id) REFERENCES Posts(id),
ADD CONSTRAINT fk_post_tags_tag_id FOREIGN KEY (tag_id) REFERENCES Tags(id);