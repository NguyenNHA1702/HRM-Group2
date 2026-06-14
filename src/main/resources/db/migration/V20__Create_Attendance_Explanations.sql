CREATE TABLE IF NOT EXISTS attendance_explanations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    attendance_date DATE NOT NULL,
    reason VARCHAR(1000) NOT NULL,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    reviewed_by INT UNSIGNED NULL,
    reviewed_at DATETIME NULL,
    review_comment VARCHAR(1000) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_attendance_explanation (employee_id, attendance_date),
    INDEX idx_attendance_explanation_status (status),
    CONSTRAINT fk_attendance_explanation_employee
        FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_explanation_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES employees(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
