-- ============================================================
-- Create table insurance_rate
-- ============================================================

CREATE TABLE IF NOT EXISTS insurance_rate (
                                              id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,

                                              name VARCHAR(100) NOT NULL,
    code VARCHAR(10) NOT NULL UNIQUE,

    employee_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    employer_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,

    note VARCHAR(255) NULL,

    is_active TINYINT(1) NOT NULL DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_is_active (is_active)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Insert default insurance rates
-- ============================================================

INSERT INTO insurance_rate
(name, code, employee_rate, employer_rate, note, is_active)
VALUES
    ('Bảo hiểm xã hội', 'BHXH', 8.00, 17.50, 'NLĐ: 8% | DN: 17.5% — Theo Luật BHXH 2014', 1),
    ('Bảo hiểm y tế', 'BHYT', 1.50, 3.00, 'NLĐ: 1.5% | DN: 3% — Theo Luật BHYT 2008', 1),
    ('Bảo hiểm thất nghiệp', 'BHTN', 1.00, 1.00, 'NLĐ: 1% | DN: 1% — Theo Luật Việc làm 2013', 1),
    ('Quỹ hưu trí bổ sung tự nguyện', 'BHKT', 1.00, 1.00, 'Tự nguyện — Theo Nghị định 88/2016/NĐ-CP', 1)
    ON DUPLICATE KEY UPDATE
                         name = VALUES(name),
                         employee_rate = VALUES(employee_rate),
                         employer_rate = VALUES(employer_rate),
                         note = VALUES(note),
                         is_active = VALUES(is_active);