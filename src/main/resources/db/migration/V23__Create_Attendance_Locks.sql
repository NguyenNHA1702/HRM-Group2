CREATE TABLE IF NOT EXISTS attendance_locks (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    year INT NOT NULL,
    month INT NOT NULL,
    is_locked BOOLEAN NOT NULL DEFAULT TRUE,
    locked_by INT UNSIGNED NULL,
    locked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_year_month (year, month),
    CONSTRAINT fk_attendance_lock_by
        FOREIGN KEY (locked_by) REFERENCES employees(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
