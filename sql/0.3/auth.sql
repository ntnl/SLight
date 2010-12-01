-- Tables needed for authentication and authorization

PRAGMA foreign_keys = ON;

CREATE TABLE User_Entity (
	`id` INTEGER PRIMARY KEY, -- must be an integer, to have AUTOINCREMENT on it

	`login` VARCHAR(64) NOT NULL,
		-- User's login

    `status` VARCHAR(10) NOT NULL,

    `name`      VARCHAR(128),

    `pass_enc` VARCHAR(512),

    `Email_id` INTEGER NOT NULL,
        -- Primary email owned and used by the User.

    `avatar_Asset_id` INTEGER,
        -- User's 'Avatar' image.

    FOREIGN KEY(`Email_id`)       REFERENCES Email(`id`),
    FOREIGN KEY(`avatar_Asset_id` REFERENCES Asset_Entity(`id`)
);
CREATE UNIQUE INDEX User_Entity_login ON User_Entity (login);
CREATE        INDEX User_Entity_email ON User_Entity (Email_id);

-- Two tables bellow define what functionality can be used by given User.

CREATE TABLE System_Access (
    user_type       VARCHAR(16) NOT NULL,
        -- One of: 'Guest', 'Authenticated'

    handler_family VARCHAR(128) NOT NULL,
    handler_class  VARCHAR(128) NOT NULL,
    handler_action VARCHAR(128) NOT NULL,
        -- Asterisk (*) means 'any' and suits as a wild-card.
        -- 'handler_object' is not present, as this table only outlines basic access rights.

    policy VARCHAR(16) NOT NULL
        -- One of: GRANTED, DENIED
);
CREATE UNIQUE INDEX System_Access_target ON System_Access (`user_type`, `handler_family`, `handler_class`, `handler_action`);

CREATE TABLE User_Access (
    User_id INTEGER NOT NULL,

    handler_family VARCHAR(128) NOT NULL,
    handler_class  VARCHAR(128) NOT NULL,
    handler_action VARCHAR(128) NOT NULL,
        -- Asterisk (*) means 'any' and suits as a wild-card.

    handler_object VARCHAR(128) NOT NULL,

    policy VARCHAR(16) NOT NULL,
        -- One of: GRANTED, DENIED

    FOREIGN KEY(`User_id`) REFERENCES User_Entity(`id`),
);
CREATE UNIQUE INDEX User_Access_target ON User_Access (`User_id`, `handler_family`, `handler_class`, `handler_action`, `handler_object`);

