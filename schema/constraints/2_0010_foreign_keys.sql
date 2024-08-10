-- Foreign key constraints for Posts
ALTER TABLE BLOG_POSTS
ADD CONSTRAINT fk_posts_user_id FOREIGN KEY (user_id) REFERENCES USERS(id),
ADD CONSTRAINT fk_posts_category_id FOREIGN KEY (category_id) REFERENCES CATEGORIES(id);

-- Foreign key constraints for Comments
ALTER TABLE COMMENTS
ADD CONSTRAINT fk_comments_post_id FOREIGN KEY (post_id) REFERENCES BLOG_POSTS(id),
ADD CONSTRAINT fk_comments_user_id FOREIGN KEY (user_id) REFERENCES USERS(id);

-- Foreign key constraints for Post_Tags
ALTER TABLE POST_TAGS
ADD CONSTRAINT fk_post_tags_post_id FOREIGN KEY (post_id) REFERENCES BLOG_POSTS(id),
ADD CONSTRAINT fk_post_tags_tag_id FOREIGN KEY (tag_id) REFERENCES TAGS(id);