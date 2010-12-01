-- Tables used to sign stuff (Content, Assets, etc) using emails.

PRAGMA foreign_keys = ON;

CREATE TABLE Email (
	`id` INTEGER PRIMARY KEY, -- must be an integer, to have AUTOINCREMENT on it

    `status`    CHAR(1) NOT NULL,
        
    `email`     VARCHAR(255) NOT NULL,

    `user_id` INTEGER,
        -- ID of the User owning this email (NULL if it was not claimed - owned by some Guest)

    FOREIGN KEY(`user_id`) REFERENCES User_Entity(`id`)
);
CREATE UNIQUE INDEX Email_email ON Email (email);

CREATE TABLE Email_Verification_Key (
	`id` INTEGER PRIMARY KEY, -- must be an integer, to have AUTOINCREMENT on it

    `Email_id`  INTEGER      NOT NULL,
    `key`       VARCHAR(128) NOT NULL,  -- 'secret' key, known only to email owner

    `metadata` TEXT,
        -- Serialized with YAML.
        -- A place where additional key-related information may be stored.

    FOREIGN KEY(`Email_id`) REFERENCES Email(`id`)
);
CREATE UNIQUE INDEX EVK_key ON Email_Verification_Key (key);

