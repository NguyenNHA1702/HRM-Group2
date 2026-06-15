-- V18: Add file_url column to contracts table conditionally
DROP PROCEDURE IF EXISTS AddColumnIfNotExists;

DELIMITER //

CREATE PROCEDURE AddColumnIfNotExists()
BEGIN
    DECLARE _count INT;
    SELECT COUNT(*) INTO _count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'contracts'
      AND COLUMN_NAME = 'file_url';

    IF _count = 0 THEN
        ALTER TABLE contracts
            ADD COLUMN file_url VARCHAR(500) NULL COMMENT 'Đường dẫn file hợp đồng (URL hoặc path)' AFTER description;
    END IF;
END //

DELIMITER ;

CALL AddColumnIfNotExists();
DROP PROCEDURE AddColumnIfNotExists;

