-- Tables needed for authentication and authorization

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

CREATE TABLE Email_Verification_Keys (
	`id` INTEGER PRIMARY KEY, -- must be an integer, to have AUTOINCREMENT on it

    `email_id`  INTEGER      NOT NULL,
    `key`       VARCHAR(128) NOT NULL,  -- 'secret' key, known only to email owner

    `handler`   VARCHAR(128) NOT NULL,  -- module, that will do the verification
    `params`    VARCHAR(255) NOT NULL,  -- parameters passed to the module

    FOREIGN KEY(`email_id`) REFERENCES Email(`id`)
);

CREATE TABLE User_Entity (
	`id` INTEGER PRIMARY KEY, -- must be an integer, to have AUTOINCREMENT on it

	`login` VARCHAR(64) NOT NULL,
		-- User's login

    `status` VARCHAR(10) NOT NULL,

    `name`      VARCHAR(128),

    `pass_enc` VARCHAR(512),
    `email_id` INTEGER NOT NULL,
        -- Primary email owned and used by the User.

    FOREIGN KEY(`email_id`) REFERENCES Email(`id`)
);
CREATE UNIQUE INDEX User_Entity_login ON User_Entity (login);
CREATE        INDEX User_Entity_email ON User_Entity (email_id);

