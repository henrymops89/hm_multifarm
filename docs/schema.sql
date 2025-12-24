-- ================================================
-- MULTI-FARM v1.0 - COMPLETE DATABASE SCHEMA
-- Kühe, Hühner, Schweine
-- Features: Slots System + Stats System + Growth System
-- ================================================

-- ================================================
-- SLOTS TABLE (für ALLE Tierarten!)
-- ================================================
CREATE TABLE IF NOT EXISTS `multifarm_slots` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `slot_number` INT(11) NOT NULL,
    `animal_type` ENUM('cow', 'chicken', 'pig') NOT NULL,
    `pos_x` FLOAT NOT NULL,
    `pos_y` FLOAT NOT NULL,
    `pos_z` FLOAT NOT NULL,
    `heading` FLOAT NOT NULL DEFAULT 0.0,
    `is_occupied` TINYINT(1) NOT NULL DEFAULT 0,
    `occupied_by` INT(11) NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `slot_animal_number` (`animal_type`, `slot_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================
-- OWNED ANIMALS TABLE (für ALLE Tierarten!)
-- ================================================
CREATE TABLE IF NOT EXISTS `multifarm_owned` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner` VARCHAR(60) NOT NULL,
    `animal_type` ENUM('cow', 'chicken', 'pig') NOT NULL,
    `breed_id` VARCHAR(50) NOT NULL,
    `slot_id` INT(11) NOT NULL,
    `custom_name` VARCHAR(50) NULL DEFAULT NULL,
    
    -- Growth System
    `stage` INT(11) NOT NULL DEFAULT 1,
    `age_days` INT(11) NOT NULL DEFAULT 0,
    `growth_stage` INT(11) NOT NULL DEFAULT 0,
    `max_growth` INT(11) NOT NULL DEFAULT 100,
    
    -- Production Tracking
    `purchased_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_collected` DATETIME NULL DEFAULT NULL,
    `total_produced` INT(11) NOT NULL DEFAULT 0,
    
    -- Stats System (für Fütterung, Pflege, Events)
    `health` INT(11) NOT NULL DEFAULT 100,
    `hunger` INT(11) NOT NULL DEFAULT 100,
    `happiness` INT(11) NOT NULL DEFAULT 100,
    `cleanliness` INT(11) NOT NULL DEFAULT 100,
    
    PRIMARY KEY (`id`),
    KEY `owner` (`owner`),
    KEY `slot_id` (`slot_id`),
    KEY `animal_type` (`animal_type`),
    CONSTRAINT `fk_multifarm_slot` 
        FOREIGN KEY (`slot_id`) 
        REFERENCES `multifarm_slots` (`id`) 
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================
-- INSERT DEFAULT SLOTS
-- 10 Kühe + 10 Hühner + 10 Schweine = 30 total
-- ================================================

-- KUH-SLOTS (1-10)
INSERT INTO `multifarm_slots` (`slot_number`, `animal_type`, `pos_x`, `pos_y`, `pos_z`, `heading`) VALUES
(1, 'cow', 2432.4, 4802.8, 34.3, 138.3),
(2, 'cow', 2442.7, 4793.6, 34.6, 136.9),
(3, 'cow', 2449.5, 4787.4, 34.6, 131.20),
(4, 'cow', 2457.7, 4778.2, 34.5, 130.5),
(5, 'cow', 2464.9, 4769.8, 34.3, 129.8),
(6, 'cow', 2473.0, 4761.5, 34.3, 130.6),
(7, 'cow', 2494.7, 4763.5, 34.3, 131.6),
(8, 'cow', 2503.4, 4754.3, 34.3, 137.2),
(9, 'cow', 2512.7, 4746.4, 34.3, 130.5),
(10, 'cow', 2519.9, 4737.82, 34.2, 152.9)
ON DUPLICATE KEY UPDATE `slot_number` = `slot_number`;

-- HÜHNER-SLOTS (1-10)
INSERT INTO `multifarm_slots` (`slot_number`, `animal_type`, `pos_x`, `pos_y`, `pos_z`, `heading`) VALUES
(1, 'chicken', 2300.5, 4947.2, 41.5, 45.0),
(2, 'chicken', 2303.2, 4950.1, 41.5, 45.0),
(3, 'chicken', 2305.8, 4952.8, 41.5, 45.0),
(4, 'chicken', 2308.5, 4955.5, 41.5, 45.0),
(5, 'chicken', 2297.8, 4944.5, 41.5, 45.0),
(6, 'chicken', 2295.1, 4941.8, 41.5, 45.0),
(7, 'chicken', 2292.4, 4939.1, 41.5, 45.0),
(8, 'chicken', 2289.7, 4936.4, 41.5, 45.0),
(9, 'chicken', 2311.2, 4958.2, 41.5, 45.0),
(10, 'chicken', 2313.9, 4960.9, 41.5, 45.0)
ON DUPLICATE KEY UPDATE `slot_number` = `slot_number`;

-- SCHWEINE-SLOTS (1-10)
INSERT INTO `multifarm_slots` (`slot_number`, `animal_type`, `pos_x`, `pos_y`, `pos_z`, `heading`) VALUES
(1, 'pig', 2364.2, 5053.7, 46.5, 90.0),
(2, 'pig', 2368.3, 5057.6, 46.5, 90.0),
(3, 'pig', 2372.4, 5061.5, 46.5, 90.0),
(4, 'pig', 2376.5, 5065.4, 46.5, 90.0),
(5, 'pig', 2360.1, 5049.8, 46.5, 90.0),
(6, 'pig', 2356.0, 5045.9, 46.5, 90.0),
(7, 'pig', 2351.9, 5042.0, 46.5, 90.0),
(8, 'pig', 2347.8, 5038.1, 46.5, 90.0),
(9, 'pig', 2380.6, 5069.3, 46.5, 90.0),
(10, 'pig', 2384.7, 5073.2, 46.5, 90.0)
ON DUPLICATE KEY UPDATE `slot_number` = `slot_number`;

-- ================================================
-- CLEANUP PROCEDURE
-- ================================================

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS CleanupZombieSlots()
BEGIN
    UPDATE multifarm_slots 
    SET is_occupied = 0, occupied_by = NULL 
    WHERE is_occupied = 1 
    AND occupied_by NOT IN (SELECT id FROM multifarm_owned);
END$$
DELIMITER ;

-- ================================================
-- TRIGGER: Auto-cleanup on animal delete
-- ================================================

DELIMITER $$
CREATE TRIGGER IF NOT EXISTS `multifarm_animal_deleted` 
AFTER DELETE ON `multifarm_owned`
FOR EACH ROW
BEGIN
    UPDATE `multifarm_slots` 
    SET `is_occupied` = 0, `occupied_by` = NULL 
    WHERE `id` = OLD.slot_id;
END$$
DELIMITER ;

