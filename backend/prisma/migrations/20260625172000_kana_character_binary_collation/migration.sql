-- Keep kana variants distinct in the unique index, for example か/が and は/ば/ぱ.
ALTER TABLE `Kana` DROP INDEX `Kana_type_character_key`;

ALTER TABLE `Kana`
  MODIFY `character` VARCHAR(191)
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_bin
  NOT NULL;

CREATE UNIQUE INDEX `Kana_type_character_key` ON `Kana`(`type`, `character`);
