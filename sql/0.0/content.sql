-- Content sub-system.

PRAGMA foreign_keys = ON;

CREATE TABLE Page_Entity (
	`id`       INTEGER PRIMARY KEY,

    `parent_id` INTEGER,
		-- our parent, or NULL on top-level comments.

	`path`      VARCHAR(127) NOT NULL,

    `template` VARCHAR(128),

    FOREIGN KEY (`parent_id`) REFERENCES Page_Entity (`id`) ON DELETE CASCADE
);
CREATE UNIQUE INDEX Page_Entity_id   ON Page_Entity (id);
CREATE UNIQUE INDEX Page_Entity_path ON Page_Entity (parent_id, path);

-- Content types subsystem
CREATE TABLE Content_Spec (
	`id`     	INTEGER PRIMARY KEY,

	`caption`	VARCHAR(128) NOT NULL,
		-- This will be a textual description, visible only to Site owner.

    `owning_module` VARCHAR(128) NOT NULL,
        -- Which module created this Spec and should be use to handle Entities derived from it.

	`version` SMALLINT NOT NULL DEFAULT 0,
		-- In case the same module can handle different versions of the content type...

    `metadata` TEXT
        -- Serialized with YAML.
        -- A place where modules can put 'their' stuff.

);
CREATE INDEX Content_Spec_module ON Content_Spec (owning_module);

CREATE TABLE Content_Spec_Field (
	`id`		INTEGER PRIMARY KEY,

    `Content_Spec_id` INTEGER,
        -- Points to Content_Spec that owns this field.

	`class`	VARCHAR(64) NOT NULL,
        -- Textual identifiers, made by the User.
		-- Must be unique in the scope of the single Type
        -- This is used to identify fields in CSS, HTML, XML and JSON

	`caption`   VARCHAR(128) NOT NULL,
        -- This will be a textual description, intended for Site owner.
        -- SLight will push it trough L10N sub-system, each time it will output it.

	`order`		SMALLINT NOT NULL,

	`datatype`  VARCHAR(64)  NOT NULL,
		-- One of:
		--	Date
		--	Time
		--	DateTime
		--
		--	Email
		--	Link
		--
		--	Int
		--	Money
		--
		--	String
		--	Text
		--
		--  Image
		--	Asset
		--
		--	Test

	`default`   VARCHAR(255) NOT NULL,
        -- Default value used to initialize the Add form.

	`translate` SMALLINT NOT NULL,
        -- 0 : Not translatable
        -- 1 : This field is translatable

    `display_on_page` SMALLINT NOT NULL DEFAULT 2,
        -- If/how to display on page
        --  0 - Do not display
        --  1 - Display as summary
        --  2 - Display in full form

    `display_on_list` SMALLINT NOT NULL DEFAULT 2,
        -- If/how to display on lists
        --  0 - Do not display
        --  1 - Display as summary
        --  2 - Display in full form

    `display_label` SMALLINT NOT NULL DEFAULT 1,
        -- Controls, where a label should be shown, when the field data is shown.
        -- 0 - display on pages and on lists.
        -- 1 - only on lists.
        -- 2 - only on pages.
        -- 3 - do not display (only on forms)

    `optional` SMALLINT NOT NULL DEFAULT 1,
        -- Controls, if filling this field will be optional
        -- 0 - no, it is always required
        -- 1 - yes, it is optional, it may be empty.

    `max_length` INTEGER NOT NULL DEFAULT 100,
        -- Controls the maximal number of characters, a field can accept.
        -- This is the number of UTF-8 characters, not bytes!
        --
        -- This value will be used to determine maximal size of file uploads too.
        -- But, for uploads - it's bytes, since files tend to be binary ;)
	
    FOREIGN KEY(`Content_Spec_id`) REFERENCES Content_Spec(`id`)
);
CREATE        INDEX Content_Spec_Field_Content_Spec_id ON Content_Spec_Field (Content_Spec_id);
CREATE UNIQUE INDEX Content_Spec_Field_class           ON Content_Spec_Field (Content_Spec_id, class);

-- Content system

CREATE TABLE Content_Entity (
    `id` INTEGER PRIMARY KEY,

    `Content_Spec_id` INTEGER NOT NULL,
        -- Which type describes this one.

    `Email_id` INTEGER,
        -- Owner's Email ID.
		-- This may lead to an User account if the entity was written by a User

	`status` CHAR(1) NOT NULL,
		-- V = visible
        -- A = archived (does not appear on lists, but is otherwise fully accessible)
        -- H = hidden (only visible to owner)

	`comment_write_policy` SMALLINT NOT NULL DEFAULT 0,
		-- Defines policy for making comments (replies, opinions, etc):
        --  0 - disabled
        --  1 - by registered users only (moderated)
        --  2 - by registered users only
        --  3 - by all users (moderated)
        --  4 - by all users 

    `comment_read_policy` SMALLINT NOT NULL DEFAULT 0,
		-- Defines policy for making comments (replies, opinions, etc):
        --  0 - comments are hidden
        --  1 - visible to registered users only
        --  2 - visible to everyone

	`added_time`	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		-- Time, when this entry was added.

	`modified_time`	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		-- Time, when this entry had it's most recent change.

    `metadata` TEXT,
        -- Serialized with YAML.
        -- A place where modules can put 'their' stuff.

    FOREIGN KEY(`Email_id`)        REFERENCES Email(`id`),
	FOREIGN KEY(`Content_Spec_id`) REFERENCES Content_Spec(`id`)
);

CREATE TABLE Content_Entity_Data (
	`Content_Entity_id` INTEGER NOT NULL,

    `Content_Spec_Field_id` INTEGER NOT NULL,
		-- this is the primary index column from Content_Spec_Field.

	`language` CHAR(5) NOT NULL,
        -- 2 (pl) or 5 (pl_pl) character language code, if the field is translatable.
        -- * if the field is not translatable.

	`value`	TEXT NOT NULL,

	FOREIGN KEY(`Content_Entity_id`)     REFERENCES Content_Entity(`id`),
    FOREIGN KEY(`Content_Spec_Field_id`) REFERENCES Content_Spec_Field(`id`)
);
CREATE UNIQUE INDEX Content_Entity_Data_index ON Content_Entity_Data (Content_Entity_id, Content_Spec_Field_id, language);

-- This table will tend to grow, thus it's indexes may be sub-optimal.
-- It should not be a problem, as it should not be used on regular basis.
CREATE TABLE Content_Entity_Data_History (
    `id` INTEGER PRIMARY KEY,

	`Content_Entity_id` INTEGER NOT NULL,

    `Content_Spec_Field_id` INTEGER NOT NULL,
		-- this is the primary index column from Content_Spec_Field.

	`language` CHAR(5) NOT NULL,
        -- 2 (pl) or 5 (pl_pl) character language code, if the field is translatable.
        -- * if the field is not translatable.

	`value`	TEXT NOT NULL,
	
    `event_time`	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        -- Time when given value was set.

	FOREIGN KEY(`Content_Entity_id`)     REFERENCES Content_Entity(`id`),
    FOREIGN KEY(`Content_Spec_Field_id`) REFERENCES Content_Type_Field(`id`)
);

CREATE TABLE Comment_Entity (
	`id` INTEGER PRIMARY KEY,

	`parent_id` INTEGER,
		-- our parent, or NULL on top-level comments.

    `Email_id` INTEGER,
        -- User's Email ID.
		-- This in turn will lead to an user account, or not (if the comment was written by guest)

	`added`	    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

	`status` VARCHAR(64) NOT NULL,
		-- visible / hidden / email_pending

	`title`	VARCHAR(255),
	`text`	TEXT,

    FOREIGN KEY (`parent_id`) REFERENCES Comment_Entity (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`Email_id`)  REFERENCES Email(`id`)
);
CREATE INDEX Comment_Entity_parent ON Comment_Entity (`parent_id`);
CREATE INDEX Comment_Entity_email  ON Comment_Entity (`Email_id`);

CREATE TABLE Asset_Entity (
	`id` INTEGER PRIMARY KEY,

	`added` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    `Email_id` INTEGER,
        -- User's Email ID.
		-- This in turn will lead to an user account, or not (if the comment was written by guest)

	`filename`	VARCHAR(255), -- original file name.
	`byte_size`	INTEGER,
    `mime_type` VARCHAR(128),

	`summary`	VARCHAR(255), -- summary entered by the uploader

	FOREIGN KEY(`Email_id`) REFERENCES Email(`id`)
);
CREATE INDEX Asset_Entity_email ON Asset_Entity (`Email_id`);



CREATE TABLE Comment_to_Content (
    Content_Entity_id INTEGER NOT NULL,
    Comment_Entity_id INTEGER NOT NULL,

    FOREIGN KEY (`Content_Entity_id`) REFERENCES Content_Entity (`id`),
    FOREIGN KEY (`Comment_Entity_id`) REFERENCES Comment_Entity (`id`)
);
CREATE UNIQUE INDEX Comment_to_Content_index ON Comment_to_Content (Content_Entity_id, Comment_Entity_id);

CREATE TABLE Comment_to_User (
    `User_Entity_id`    INTEGER NOT NULL,
    `Comment_Entity_id` INTEGER NOT NULL,

    FOREIGN KEY (`User_Entity_id`)    REFERENCES User_Entity (`id`),
    FOREIGN KEY (`Comment_Entity_id`) REFERENCES Comment_Entity (`id`)
);
CREATE UNIQUE INDEX Comment_to_User_index ON Comment_to_User (User_Entity_id, Comment_Entity_id);

CREATE TABLE Comment_to_Asset (
    `Asset_Entity_id`   INTEGER NOT NULL,
    `Comment_Entity_id` INTEGER NOT NULL,

    FOREIGN KEY (`Asset_Entity_id`)   REFERENCES Asset_Entity   (`id`),
    FOREIGN KEY (`Comment_Entity_id`) REFERENCES Comment_Entity (`id`)
);
CREATE UNIQUE INDEX Comment_to_Asset_index ON Comment_to_Asset (Asset_Entity_id, Comment_Entity_id);



CREATE TABLE Asset_to_Content (
    `Comment_Entity_id` INTEGER NOT NULL,
    `Asset_Entity_id`   INTEGER NOT NULL,

    `Content_Spec_Field_id` INTEGER,

    FOREIGN KEY (`Comment_Entity_id`) REFERENCES Comment_Entity (`id`),
    FOREIGN KEY (`Asset_Entity_id`)   REFERENCES Asset_Entity   (`id`)
);
CREATE UNIQUE INDEX Asset_to_Content_index ON Comment_to_Content (Content_Entity_id, Comment_Entity_id);

CREATE TABLE Asset_to_User (
    `User_Entity_id`  INTEGER NOT NULL,
    `Asset_Entity_id` INTEGER NOT NULL,

    `field` VARCHAR(64) NOT NULL,

    FOREIGN KEY (`User_Entity_id`)  REFERENCES User_Entity (`id`),
    FOREIGN KEY (`Asset_Entity_id`) REFERENCES Asset_Entity (`id`)
);
CREATE UNIQUE INDEX Asset_to_User_index ON Comment_to_User (User_Entity_id, Comment_Entity_id);

