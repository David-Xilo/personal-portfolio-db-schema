CREATE TABLE IF NOT EXISTS Post_Tags (
    post_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES Posts(id),
    FOREIGN KEY (tag_id) REFERENCES Tags(id)
);