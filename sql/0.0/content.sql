-- Content sub-system.

PRAGMA foreign_keys = ON;

CREATE TABLE Page_Entity (
	`id`       INTEGER PRIMARY KEY,

    `parent_id` INTEGER,
	`path`      VARCHAR(127) NOT NULL,

    `template` VARCHAR(128),

    FOREIGN KEY (`parent_id`) REFERENCES Page_Entity (`id`) ON DELETE CASCADE
);
CREATE UNIQUE INDEX Page_Entity_id   ON Page_Entity (id);
CREATE UNIQUE INDEX Page_Entity_path ON Page_Entity (parent_id, path);

-- Content types subsystem
CREATE TABLE Content_Type (
	`id`     	INTEGER PRIMARY KEY,

	`caption`	VARCHAR(128) NOT NULL,
		-- This will either be a textual description,
		-- or code-name (for system ContentTypes)

    `owning_module` VARCHAR(128),
        -- Which module handles this type of items.

    `metadata` TEXT
        -- Serialized with YAML.
        -- A place where modules can put 'their' stuff.

);
CREATE INDEX Content_Type_module ON ContentType (owning_module);

CREATE TABLE Content_Type_Field (
	`id`		INTEGER PRIMARY KEY,

    `ContentType_id` INTEGER NOT NULL,

	`type_id`	VARCHAR(64) NOT NULL,
        -- field name, textual

	`order`		SMALLINT NOT NULL,

	`caption`   VARCHAR(128) NOT NULL,
	`datatype`  VARCHAR(64)  NOT NULL,
	`default`   VARCHAR(255) NOT NULL,
	`translate` SMALLINT NOT NULL,
        -- 0 : Do not translate
        -- 1 : This field is translatable

    `display`   SMALLINT NOT NULL DEFAULT 2,
        -- Should this entry be included, when preparing lists
        -- 0 - include both on pages and on lists.
        -- 1 - only on lists.
        -- 2 - only on pages.
        -- 3 - do not display (only on forms)

    `use_label` SMALLINT NOT NULL DEFAULT 2,
        -- Controls, where a label should be shown, when the field data is shown.
        -- 0 - display on pages and on lists.
        -- 1 - only on lists.
        -- 2 - only on pages.
        -- 3 - do not display (only on forms)

    `optional` SMALLINT NOT NULL DEFAULT 1,
        -- Controls, if filling this field will be optional
        -- 0 - no, it is always required
        -- 1 - yes, it is optional, it may be empty.

    `max_length` INTEGER NOT NULL DEFAULT 100
        -- Controls the maximal number of characters, a field can accept.
        -- This is the number of UTF-8 characters, not bytes!
        --
        -- This value will be used to determine maximal size of file uploads too.
        -- But, for uploads - it's bytes, since files tend to be binary ;)
);
CREATE INDEX Content_Type_Field_type_id ON ContentTypeField (type_id);

-- Content system

CREATE TABLE Content_Entity (
    `id` INTEGER PRIMARY KEY,

    `ContentEntry_id` INTEGER,
		-- our parent

    `ContentType_id` INTEGER NOT NULL,
        -- Which type describes this one.

    `email_id` INTEGER,
        -- User's Email ID.
		-- This in turn will lead to an user account, or not (if the comment was written by guest)

	`status`	VARCHAR(64),
		-- visible / hidden

    `revision` SMALLINT NOT NULL DEFAULT 1,
        -- This will be increased each time this entry
        -- (either meta-, or data part) changes

	`comments` INTEGER NOT NULL DEFAULT 0,
		-- Defines policy for comments:
		--	0 : Open             : read: any, write: any
		--  1 : Open moderated   : read: any, write: registered
		--	2 : Open disabled    : read: any, write: no one
		--  3 : Private          : read: registered, write: registered
		--  4 : Private disabled : read: registered, write: no one
		--  5 : Disabled         : read: no one, write: no one
		-- Note, that You also need Post grant on Comment::Write to be able to write ANY comments.
		-- Fixme: this may be partially implemented :(

	`added_time`	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		-- Time, when this entry was added.
	`modified_time`	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		-- Time, when this entry had it's most recent change.

    FOREIGN KEY(`Email_id`)        REFERENCES Email(`id`),
	FOREIGN KEY(`Content_Type_id`) REFERENCES Content_Type(`id`)
);

CREATE TABLE Content_Entity_Data (
	`ContentEntry_id` INTEGER NOT NULL,

    `ContentTypeField_id` INTEGER NOT NULL,
		-- this is the primary index column from ContentTypeField.

	`language` CHAR(5),
        -- 2 (pl) or 5 (pl_pl) character language code, if the field is translatable.
        -- * if the field is not translatable.

	`value`	TEXT,

	FOREIGN KEY(`Content_Entity_id`)     REFERENCES Content_Entity(`id`),
    FOREIGN KEY(`Content_Type_Field_id`) REFERENCES Content_Type_Field(`id`)
);
CREATE UNIQUE INDEX Content_Entry_Data_index ON ContentEntryData (ContentEntry_id, ContentTypeField_id, language);

