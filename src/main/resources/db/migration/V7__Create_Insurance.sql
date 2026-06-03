-- ============================================================
-- V6__Create_Insurance_Config.sql
-- Tạo bảng cấu hình bảo hiểm theo từng nhân viên
-- ============================================================

-- KHÔNG cần USE hrm_db;
-- Vì FlywayConfig đã connect trực tiếp vào database hrm_db / HRM_DB rồi.

CREATE TABLE IF NOT EXISTS insurance_config (
                                                id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,

                                                employee_id INT UNSIGNED NOT NULL,

                                                insurance_number VARCHAR(20) NOT NULL UNIQUE,

    bhxh_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    bhyt_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    bhtn_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,

    base_salary DECIMAL(15,2) NOT NULL DEFAULT 0.00,

    bhxh_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    bhyt_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    bhtn_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,

    is_active TINYINT(1) NOT NULL DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_ic_employee
    FOREIGN KEY (employee_id)
    REFERENCES employees(id)
                                                   ON DELETE CASCADE
                                                   ON UPDATE CASCADE,

    CONSTRAINT uq_ic_employee
    UNIQUE (employee_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Insert dữ liệu mẫu
-- Dựa theo employee_id đang có trong bảng user_accounts:
-- 1, 2, 4, 5, 7, 9, 10, 12, 14, 15, 16
-- ============================================================

INSERT IGNORE INTO insurance_config
(employee_id, insurance_number, bhxh_rate, bhyt_rate, bhtn_rate,
 base_salary, bhxh_amount, bhyt_amount, bhtn_amount, total_amount, is_active)
VALUES
(1,  'BH000001', 8.00, 1.50, 1.00, 10000000.00, 800000.00, 150000.00, 100000.00, 1050000.00, 1),
(2,  'BH000002', 8.00, 1.50, 1.00, 8000000.00,  640000.00, 120000.00, 80000.00,  840000.00,  1),
(4,  'BH000004', 8.00, 1.50, 1.00, 9000000.00,  720000.00, 135000.00, 90000.00,  945000.00,  1),
(5,  'BH000005', 8.00, 1.50, 1.00, 11000000.00, 880000.00, 165000.00, 110000.00, 1155000.00, 1),
(7,  'BH000007', 8.00, 1.50, 1.00, 9500000.00,  760000.00, 142500.00, 95000.00,  997500.00,  1),
(9,  'BH000009', 8.00, 1.50, 1.00, 12000000.00, 960000.00, 180000.00, 120000.00, 1260000.00, 1),
(10, 'BH000010', 8.00, 1.50, 1.00, 8500000.00,  680000.00, 127500.00, 85000.00,  892500.00,  1),
(12, 'BH000012', 8.00, 1.50, 1.00, 10000000.00, 800000.00, 150000.00, 100000.00, 1050000.00, 1),
(14, 'BH000014', 8.00, 1.50, 1.00, 10000000.00, 800000.00, 150000.00, 100000.00, 1050000.00, 1),
(15, 'BH000015', 8.00, 1.50, 1.00, 10000000.00, 800000.00, 150000.00, 100000.00, 1050000.00, 1),
(16, 'BH000016', 8.00, 1.50, 1.00, 10000000.00, 800000.00, 150000.00, 100000.00, 1050000.00, 1);