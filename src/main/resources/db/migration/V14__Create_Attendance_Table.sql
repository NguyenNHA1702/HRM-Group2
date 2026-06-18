CREATE TABLE IF NOT EXISTS attendance (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    check_in TIME NULL,
    check_out TIME NULL,
    status ENUM('PRESENT', 'LATE', 'EARLY_LEAVE', 'ABSENT', 'HOLIDAY', 'LEAVE')
        NOT NULL DEFAULT 'ABSENT',
    note TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_attendance (employee_id, date),
    INDEX idx_attendance_date (date),
    INDEX idx_attendance_employee (employee_id),
    INDEX idx_attendance_status (status),
    CONSTRAINT fk_attendance_employee
        FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
