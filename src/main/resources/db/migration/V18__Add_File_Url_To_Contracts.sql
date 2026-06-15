-- V18: Safe Add file_url column to contracts table if not exists
DROP PROCEDURE IF EXISTS AddFileUrlToContracts;

DELIMITER //

CREATE PROCEDURE AddFileUrlToContracts()
BEGIN
    DECLARE col_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO col_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'contracts'
      AND COLUMN_NAME = 'file_url';

    IF col_exists = 0 THEN
        ALTER TABLE contracts
        ADD COLUMN file_url VARCHAR(500) NULL COMMENT 'Đường dẫn file hợp đồng (URL hoặc path)' AFTER description;
    END IF;
END //

DELIMITER ;

CALL AddFileUrlToContracts();

DROP PROCEDURE IF EXISTS AddFileUrlToContracts;
