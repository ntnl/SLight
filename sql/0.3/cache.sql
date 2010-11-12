-- SQL commands needed to initialize Cache meta-data.

-- This table allows to find all entries,
-- which refer to given (numerical) ID.
CREATE TABLE Cache_Reference (
    id INTEGER NOT NULL,
        -- Referenced (numerical) ID.

    namespace VARCHAR(255) NOT NULL,
        -- Namespace name

    key VARCHAR(255) NOT NULL
        -- Key.
);
CREATE INDEX Cache_Reference_id ON Cache_Reference (id);

