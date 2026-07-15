-- V25: Fix attendance_locks unique key for department-based locking
-- V24 đã ADD COLUMN department_id nhưng DROP INDEX failed (IF EXISTS not supported)

-- Drop old unique key (tên đúng từ V23 là uk_year_month)
SET @exist := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
               WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_NAME = 'attendance_locks'
               AND INDEX_NAME = 'uk_year_month');
SET @sqlstmt := IF(@exist > 0, 'ALTER TABLE attendance_locks DROP INDEX uk_year_month', 'SELECT 1');
PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop the failed uq_year_month if it somehow exists
SET @exist2 := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'attendance_locks'
                AND INDEX_NAME = 'uq_year_month');
SET @sqlstmt2 := IF(@exist2 > 0, 'ALTER TABLE attendance_locks DROP INDEX uq_year_month', 'SELECT 1');
PREPARE stmt2 FROM @sqlstmt2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- Drop uq_year_month_dept if partially created
SET @exist3 := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'attendance_locks'
                AND INDEX_NAME = 'uq_year_month_dept');
SET @sqlstmt3 := IF(@exist3 > 0, 'ALTER TABLE attendance_locks DROP INDEX uq_year_month_dept', 'SELECT 1');
PREPARE stmt3 FROM @sqlstmt3;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

-- Delete any old rows with NULL department_id (global locks without dept)
DELETE FROM attendance_locks WHERE department_id IS NULL;

-- Create new unique key including department_id
ALTER TABLE attendance_locks ADD UNIQUE KEY uq_year_month_dept (year, month, department_id);
