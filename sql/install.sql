CREATE TABLE IF NOT EXISTS `PREFIX_elasticsearch_index_status` (
  `id_elasticsearch_index_status` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_product`                    INT(11) UNSIGNED NOT NULL,
  `id_shop`                       INT(11) UNSIGNED NOT NULL,
  `id_lang`                       INT(11) UNSIGNED NOT NULL,
  `date_upd`                      DATETIME         NOT NULL,
  `error`                         TEXT,
  PRIMARY KEY (`id_elasticsearch_index_status`),
  UNIQUE (`id_product`, `id_shop`, `id_lang`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `PREFIX_elasticsearch_meta` (
  `id_elasticsearch_meta` INT(11) UNSIGNED    NOT NULL AUTO_INCREMENT,
  `alias`                 VARCHAR(190)        NOT NULL,
  `code`                  VARCHAR(190)        NOT NULL,
  `enabled`               TINYINT(1) UNSIGNED NOT NULL DEFAULT '1',
  `meta_type`             VARCHAR(255)        NOT NULL DEFAULT 'attribute',
  `elastic_type`          VARCHAR(255)        NOT NULL DEFAULT 'text',
  `searchable`            TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
  `weight`                FLOAT               NOT NULL DEFAULT '1.00000',
  `position`              INT(11) UNSIGNED    NOT NULL,
  `aggregatable`          TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
  `operator`              TINYINT(1) UNSIGNED NOT NULL DEFAULT '1',
  `display_type`          INT(11) UNSIGNED    NOT NULL DEFAULT '1',
  `result_limit`          INT(11) UNSIGNED    NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_elasticsearch_meta`),
  UNIQUE (`alias`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `PREFIX_elasticsearch_meta_lang` (
  `id_elasticsearch_meta` INT(11) UNSIGNED NOT NULL,
  `id_lang`               INT(11) UNSIGNED NOT NULL,
  `name`                  VARCHAR(255)     NOT NULL,
  PRIMARY KEY (`id_elasticsearch_meta`, `id_lang`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
