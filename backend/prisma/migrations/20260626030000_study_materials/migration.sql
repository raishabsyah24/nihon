-- CreateTable
CREATE TABLE `StudyMaterial` (
    `id` VARCHAR(191) NOT NULL,
    `kind` ENUM('JFT_MATERIAL', 'JFT_QUESTION', 'JLPT_MATERIAL', 'JLPT_QUESTION', 'SSW_QUESTION') NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `level` VARCHAR(191) NULL,
    `category` VARCHAR(191) NULL,
    `summary` TEXT NULL,
    `content` TEXT NOT NULL,
    `sections` JSON NULL,
    `vocabulary` JSON NULL,
    `examples` JSON NULL,
    `status` ENUM('DRAFT', 'PUBLISHED') NOT NULL DEFAULT 'DRAFT',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `StudyMaterial_slug_key`(`slug`),
    INDEX `StudyMaterial_kind_level_category_idx`(`kind`, `level`, `category`),
    INDEX `StudyMaterial_status_createdAt_idx`(`status`, `createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
