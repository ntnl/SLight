--MySQL / PostgreSQL
ALTER TABLE Content_Spec_Field ADD COLUMN `field_index` SMALLINT NOT NULL;
UPDATE Content_Spec_Field SET field_index = `order`;
ALTER TABLE Content_Spec_Field DROP COLUMN `order`;

ALTER TABLE Content_Spec_Field ADD COLUMN `default_value` SMALLINT NOT NULL;
UPDATE Content_Spec_Field SET default_value = `default`;
ALTER TABLE Content_Spec_Field DROP COLUMN `default`;

-- SQLite:
BEGIN TRANSACTION;
CREATE TABLE Content_Spec_Field_new (
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

	`field_index` SMALLINT NOT NULL,

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

	`default_value` VARCHAR(255) NOT NULL,
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
        -- (Yes, after thinking it I also find this ridiculous)
        -- 0 - no, it is always required
        -- 1 - yes, it is optional, it may be empty.

    `max_length` INTEGER NOT NULL DEFAULT 100,
        -- Controls the maximal number of characters, a field can accept.
        -- This is the number of UTF-8 characters, not bytes!
        --
        -- This value will be used to determine maximal size of file uploads too.
        -- But, for uploads - it's bytes, since files tend to be binary ;)
	
    FOREIGN KEY(`Content_Spec_id`) REFERENCES Content_Spec(`id`) ON DELETE CASCADE
);

INSERT INTO Content_Spec_Field_new SELECT id, Content_Spec_id, class, caption, `order`, datatype, `default`, translate, display_on_page, display_on_list, display_label, optional, max_length  FROM Content_Spec_Field;
DROP TABLE Content_Spec_Field;
ALTER TABLE Content_Spec_Field_new RENAME TO Content_Spec_Field;
COMMIT;

