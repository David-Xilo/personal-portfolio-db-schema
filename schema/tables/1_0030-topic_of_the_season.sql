CREATE TYPE TIMEFRAME_TYPE AS ENUM ('custom', '1d', '1w', '1m', '3m', '6m', '1y');
CREATE TABLE IF NOT EXISTS TOPIC_OF_THE_SEASON (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NULL,
    deleted_at TIMESTAMP DEFAULT NULL,
    topic VARCHAR(255) NOT NULL,
    genre NEWS_GENRE NOT NULL,
    topic_timestamp TIMESTAMP NOT NULL,
    type TIMEFRAME_TYPE NOT NULL,
    custom_start TIMESTAMP,
    custom_end TIMESTAMP,
    CONSTRAINT check_timeframe_custom_dates CHECK (
        (type = 'custom' AND custom_start IS NOT NULL AND custom_end IS NOT NULL) OR
        (type <> 'custom' AND custom_start IS NULL AND custom_end IS NULL)
        )
);
