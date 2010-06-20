CREATE TABLE Page_Entity (
	`id`       INTEGER PRIMARY KEY,

    `parent_id` INTEGER,
	`path`      VARCHAR(127) NOT NULL,

    `template` VARCHAR(128),

    FOREIGN KEY (`parent_id`) REFERENCES Page_Entity (`id`) ON DELETE CASCADE
);
CREATE UNIQUE INDEX Page_Entity_id   ON Page_Entity (id);
CREATE UNIQUE INDEX Page_Entity_path ON Page_Entity (parent_id, path);

